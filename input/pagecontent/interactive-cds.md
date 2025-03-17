Interactive CDS is a process whereby the clinician facing user interface prompts for required data ([CPG Case Feature]())  via a form in order to evaluate the applicability of clinical guideline recommendations ([CPG Plan Definition]()).

### PlanDefinition $apply with questionnaire generation

Questionnaire generation may be enabled for PlanDefinition/$apply to elicit user input on required data elements as follows:

1. For each case feature definition referenced from PlanDefinition action.input, call [StructureDefinition/$questionnaire](https://hl7.org/fhir/R4/structuredefinition-operation-questionnaire.html) in minimal mode (differentialOnly=true). Recurse over nested plan definitions to include all case features.

2. Add each set of questions from step 1 (each corresponding to a case feature) as group items in a questionnaire to produce a single questionnaire. The questionnaire should conform to [SDC Populatable Questionnaire - Expression](http://hl7.org/fhir/uv/sdc/StructureDefinition/sdc-questionnaire-pop-exp) and [SDC Extractable Questionnaire - Definition](http://hl7.org/fhir/uv/sdc/StructureDefinition/sdc-questionnaire-extr-defn) and should align with the expected output of [Questionnaire/$assemble](https://hl7.org/fhir/uv/sdc/OperationDefinition-Questionnaire-assemble.html), although the assembly process may differ.

3. Build a pre-populated QuestionnaireResponse containing the Questionnaire from Step 2 by calling [Questionnaire/$populate](https://hl7.org/fhir/uv/sdc/OperationDefinition-Questionnaire-populate.html) using [SDC expression based population](https://hl7.org/fhir/uv/sdc/populate.html#exp-pop)

4. Pause for user input to either

   1. Change the QuestionnaireResponse and proceed to Steps 5 and 6; Or

   2. Select recommendations from the RequestGroup and end they apply cycle

5. If the QuestionnaireResponse is updated, call [QuestionnaireResponse/$extract](https://hl7.org/fhir/uv/sdc/OperationDefinition-QuestionnaireResponse-extract.html) using [SDC definition based extraction](https://hl7.org/fhir/uv/sdc/extraction.html#definition-extract) to create new resources based on QuestionnaireResponse from Steps 3 and 4

6. If there are new resources from Step 5, pass to the context and call [PlanDefinition/$apply](https://build.fhir.org/ig/HL7/cqf-recommendations/OperationDefinition-cpg-plandefinition-apply.html). The cycle repeats.

In this way, $questionnaire is used with $apply and existing SDC operations to

1. Prompt users for required data;
2. Pre-populate answers based on documented case features and/or inferencing rules;
3. Confirm pre-populated data; and
4. Extract new data to update the recommendations

### Questionnaire Processing Semantics

To enable questionnaire generation based on CPG Case Features, $questionnaire can be called with StructureDefinition and PlanDefinition.

#### StructureDefinition/$questionnaire

See [core $questionnaire operation](https://hl7.org/fhir/R4/structuredefinition-operation-questionnaire.html)

The core operation is extended in CPG to support the parameter 'coreOnly'. If true, elements from the structure definition should be processed if:

1. The element is a part of the differential;
2. The element is a part of the snapshot and has a cardinality of at least 1..\* (min >1). Nested child elements with min > 1 should also be included if parent has min > 1;
3. The element is not a fixed value (fixed[x] or pattern[x])

Optionally, the parameter "supportedOnly" may be supplied. If true, the above applies only to elements with must support flags.

The goal of core only mode is to process only the elements required for definition based extraction. See [Authoring Guidance](#authoring-guidance) on best practices for authoring case feature definitions for core questionnaire generation.

<!-- What if must support and differential only are true ? -->

| elementDefinition                                     | questionnaireItem                                                      | notes                                                                                                                                                             |
| ----------------------------------------------------- | ---------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| extension[sdc-questionnaire-definitionExtractValue]   | sets extension[sdc-questionnaire-definitionExtractValue] on group item | Authored on case feature elements that will be evaluated as an expression during $extract                                                                         |
| CPG featureExpression                                 | sets [questionnaire-initialExpression]                                 | see [Conformance with expression based population and definition based extraction](#conformance-with-expression-based-population-and-definition-based-extraction) |
| {structureDefinition.url}#{element.path}              | definition                                                             | for choice type paths, replace [x] with element type.code[0]                                                                                                      |
| short description; element label; or stringified path | text                                                                   |                                                                                                                                                                   |
| type                                                  | type                                                                   | see [ElementDefinition Mappings](#mapping-elementdefinition-data-types-to-questionnaire-items)                                                                    |
| min > 0                                               | required                                                               |                                                                                                                                                                   |
| max > 1                                               | repeats                                                                |                                                                                                                                                                   |
| maxLength                                             | maxLength                                                              | apply if type = string                                                                                                                                            |
| binding.valueSet                                      | expanded valueSet used as answerOption, set type as 'choice'           |                                                                                                                                                                   |
| ??                                                    | readOnly                                                               |                                                                                                                                                                   |

Process elements from the structure definition resource. For each element to process:

  - If the element has the [SDC definition extract value extension](https://build.fhir.org/ig/HL7/sdc/StructureDefinition-sdc-questionnaire-definitionExtractValue.html), it is not necessary to create a questionnaire item. Instead, carry the extension over to the root item with type 'group'. See [details on populate and extract conformance below](#conformance-with-expression-based-population-and-definition-based-extractionconformance).

  - Otherwise, process a new child item as follows

    - If CPG case featureExpression is present, set the [SDC initial expression extension](http://hl7.org/fhir/uv/sdc/StructureDefinition/sdc-questionnaire-initialExpression). See [Conformance with expression based population and definition based extraction](#conformance-with-expression-based-population-and-definition-based-extraction)

    - QuestionnaireItem.linkId => generate some unique id

    - QuestionnaireItem.definition => "{structureDefinition.url}#{full element path}", where:

      - "full element path" is path unless the path is a choice type (e.g. 'Observation.value[x]')
      - "full element path" is path with `[x]` replaced with the first (and only) type.code

    - QuestionnaireItem.code => Not used

    - QuestionnaireItem.prefix => Not used

    - QuestionnaireItem.text in order of preference =>

      - Element short description;
      - Element label; or
      - "Stringify" the path

    - QuestionnaireItem.type (should always be primitive type) =>

      - If the element type is specified in the differential, map to Questionnaire.type
      - If the element type is not specified in the differential, use the snapshot type and map to Questionnaire.type
      - If type code, treat as a coding with type 'choice' (note: during $extract need to map this type back to code)
      - For a more detailed mapping of primitive and complex data types, see [ElementDefinition Mappings](#mapping-elementdefinition-data-types-to-questionnaire-items)

    - QuestionnaireItem.required => if (element.min > 0)

    - QuestionnaireItem.repeats => if (element.max > 1)

    - QuestionnaireItem.readOnly => Context from the corresponding data-requirement or default[x] (???)

    - QuestionnaireItem.maxLength => element.maxLength (if type is a string)

    - QuestionnaireItem.answerOption => expanded value set binding <!-- How should example binding be handled? open choice? -->

      <!-- to do: how to handle [questionnaire-unit](http://hl7.org/fhir/R4/extension-questionnaire-unit.html)-->

      <!-- to do: how to handle sliced elements-->

##### Conformance with expression based population and definition based extraction

See [SDC expression based population](https://build.fhir.org/ig/HL7/sdc/populate.html#expression-based-population) and [SDC definition based extraction](https://build.fhir.org/ig/HL7/sdc/extraction.html#definition-extract)

To conform to $populate and \$extract:

- At the root of the questionnaire, include extension [questionnaire-launchContext](https://hl7.org/fhir/uv/sdc/StructureDefinition-sdc-questionnaire-launchContext.html) for the in context subject (most often Patient), encounter, etc

- At the root item with type 'group'

  - Include the [SDC definition extract extension](http://hl7.org/fhir/uv/sdc/StructureDefinition/sdc-questionnaire-definitionExtract). Set extension[definition].valueCanonical to the canonical of the SD.

  - Carry over any [SDC definition extract value extension](https://build.fhir.org/ig/HL7/sdc/StructureDefinition-sdc-questionnaire-definitionExtractValue.html) from the structure definition.

  - If CPG featureExpression is present on the SD

    - Add the [SDC item population context extension](http://hl7.org/fhir/uv/sdc/StructureDefinition/sdc-questionnaire-itemPopulationContext) set to the CPG featureExpression;

    - For each child item, include the [questionnaire-initialExpression](https://hl7.org/fhir/uv/sdc/StructureDefinition-sdc-questionnaire-initialExpression.html) extension use the population context

##### Mapping ElementDefinition data types to Questionnaire Items

Allowed data types beteween element definition and questionnaire items differ where element definition allows for complex data types and questionnaire is restricted to primitive types, Quantity, Reference, and Coding. The data types can be mapped between SD and questionnaire as outlined in the table below.

| FHIR Primitive Type | QuestionnaireItem.initialValue[x] Type (when fixed[x] present) | QuestionnaireItem.type Code | Notes                                                            |
| ------------------- | -------------------------------------------------------------- | --------------------------- | ---------------------------------------------------------------- |
| base64Binary        | string                                                         | string                      |                                                                  |
| boolean             | boolean                                                        | boolean                     |                                                                  |
| canonical           | uri                                                            | url                         |                                                                  |
| code                | coding                                                         | choice                      | During $extract, this needs to map back from coding to code      |
| date                | date                                                           | date                        |                                                                  |
| dateTime            | dateTime                                                       | dateTime                    |                                                                  |
| decimal             | decimal                                                        | decimal                     |                                                                  |
| id                  | string                                                         | string                      |                                                                  |
| instant             | dateTime                                                       | dateTime                    |                                                                  |
| integer             | integer                                                        | integer                     |                                                                  |
| integer64           | integer                                                        | integer                     |                                                                  |
| markdown            | string                                                         | string                      |                                                                  |
| oid                 | uri                                                            | string                      |                                                                  |
| positiveInt         | integer                                                        | integer                     |                                                                  |
| string              | string                                                         | string                      |                                                                  |
| time                | time                                                           | time                        |                                                                  |
| unsignedInt         | integer                                                        | integer                     |                                                                  |
| uri                 | uri                                                            | url or string               | Check that the URI is a valid URL, if not it should be a string? |
| url                 | uri                                                            | url                         |                                                                  |
| uuid                | uri                                                            | string                      |                                                                  |

| Other Data Types  | QuestionnaireItem.initialValue[x] Type                                            | QuestionnaireItem.type Code                                          | Notes                                                                                                                                                                                                     |
| ----------------- | --------------------------------------------------------------------------------- | -------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| coding            | coding                                                                            | choice                                                               |                                                                                                                                                                                                           |
| codeableConcept   | initialValueCoding; and/or<br>initialValueString (to represent text)              | subgroup with items of type choice (coding) and string (text)??      |                                                                                                                                                                                                           |
| quantity          | quanitity                                                                         | quantity                                                             | Extension [https://hl7.org/fhir/extensions/StructureDefinition-questionnaire-unit.html](https://hl7.org/fhir/extensions/StructureDefinition-questionnaire-unit.html) can be used to capture specific unit |
| reference         | reference                                                                         | reference                                                            |                                                                                                                                                                                                           |
|                   |                                                                                   |                                                                      |                                                                                                                                                                                                           |
| complex data type | initialValue type represents each primitive type defined in the complex data type | type represents each primitive type defined in the complex data type | See example mapping below                                                                                                                                                                                 |

For non-primitive, complex data types, $questionnaire should be applied to the SD of the data type and returned as a subgroup of questionnaire items. An example of the [Range data type](https://www.hl7.org/fhir/datatypes.html#Range) represented as a group of questionnaire items follows.

```
{
  "linkId": "Range",
  "definition": "http://example.org/StructureDefinition/ExampleObservation#Observation.valueRange",
  "text": "Actual result",
  "type": "group",
  "item": [
    {
      "linkId": "Range.low",
      "definition": "http://example.org/StructureDefinition/ExamleObservation#Observation.valueQuantity.low",
      "text": "Low limit",
      "type": "quantity"
    },
    {
      "linkId": "Range.high",
      "definition": "http://example.org/StructureDefinition/ExampleObservation#Observation.valueQuantity.high",
      "text": "High limit",
      "type": "quantity"
    }
  ]
}
```

<!-- ##### Questionnaire/$populate

See [SDC expression based population](https://build.fhir.org/ig/HL7/sdc/populate.html#expression-based-population) for population details.

A pre-populated questionnaire response can be generated using the resulting questionnaire items. Item initial value or initial expression is used to set the answer value.

| questionnaireItem               | questionnaireResponseItem | notes                                           |
| ------------------------------- | ------------------------- | ----------------------------------------------- |
| initial.value[x]                | answer.value[x]           | Set by fixed[x], pattern[x], default[x] from SD |
| questionnaire-initialExpression | answer.value[x]           | Set by CPG featureExpression from SD            |

##### QuestionnaireResponse/$extract

See [SDC definition based extraction](https://build.fhir.org/ig/HL7/sdc/extraction.html#definition-extract) for extraction details.

An extracted resource is created using the QuestionnaireResponse and corresponding Questionnaire. The extracted resource will not be persisted but used as a part of the \$apply context.

If an observation, set Observation.derivedFrom to the canonical of the QuestionnaireResponse. -->

#### PlanDefinition/$questionnaire

PlanDefinition/\$questionnaire uses the same principles and methodology as StructureDefinition/\$questionnaire, but is generated from multiple StructureDefinitions. In the case of CPG PlanDefinitions, these are case feature definitions referenced from PlanDefinition action.input.

<!-- Add details on populate/extract here ? -->

The PlanDefinition is processed as follows:

1. Find all planDefinition.action.input elements where a case feature is referenced. If the plan definition includes action.definitionCanonical with a reference to another plan definition, recurse over the nested planDefinition.action.input elements as well.

2. For each case feature identified from the PlanDefinition:

   1. Generate a group of questionnaire items on the target questionnaire; or

   2. To leverage [Questionnaire/$assemble](https://hl7.org/fhir/uv/sdc/OperationDefinition-Questionnaire-assemble.html), generate an individual questionnaire for each case feature and call \$assemble to generate a single questionnaire. See [SDC modular questionnaires](https://build.fhir.org/ig/HL7/sdc/modular.html#modular) for implementation details.

#### Authoring Guidance

To support interactive CDS, case feature definitions must be authored with questionnaire generation and extraction in mind:

1. Any element that is relevant to extraction, should be included in the differential
2.

<!-- Standardize Interactive CDS
- $questionnaire operation for interactive CDS (StructureDefinition/$questionnaire)
  - existing has mustSupport
  - will add requiredOnly
- $questionnaire operation for interactive CDS (PlanDefinition/$questionnaire) - Name SDC definition-based extract as the target Questionnaire profile
  - Effectively assembles questionnaires produced by StructureDefinition/$questionnaire for all the case features referenced in the PlanDefinition.action.input
- Document that PlanDefinition/$apply can make use of PlanDefinition/$questionnaire to support the interactive CDS model
Consider:
- Minimal mode? Different institutations/implementations may want variation here?
  - Current approach is to allow authors to specify this in the action.input
  - How do we support site-specific configuration
    - Document patterns of support, currently at least configuration options (see opioid mme for examples)
    - Also support "specialization" patterns for changing PlanDefinitions/deriving new PlanDefinition
- Adaptive approach? Interactive CDS is by definition "adaptive" in that it drives off data that is available
  - Make sure we document parallels between this and adaptive (effectively $next-question is just call $apply again with the updated QuestionnaireResponse) -->
