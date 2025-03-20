<!--
Use of Snapshot:
1. For required elements not included in the differential
This may not be necessary. Fixed elements are not mapped to questionnaire items. All other required elements will likely be constrained in some way or include definition extract extensions, thus these will be part of the differential.
2. As a fallback for differential element mapping i.e. say we require subject on observation. When using FSH, the element type (Reference) is not available on the differential, so we must look at the snapshot to resolve and map to questionnaire item type

New Questionnaire parameter naming:
- differentialOnly
  Potential use of snapshot?
- requiredOnly
  The element being mapped may not necessarily be min=1 ?
- minimalMode
  It would be nice to have consistency with 'supportedOnly'
- coreOnly
 -->

Interactive Clinical Decision Support (CDS) is a process where the clinician-facing interface prompts for required data via a form in order to evaluate the applicability of clinical guideline recommendations.

The \$questionnaire operation is used with PlanDefinition \$apply and existing Structured Data Capture (SDC) operations to:

1. Prompt users for required data;
2. Pre-populate answers based on documented case features and/or inferencing rules;
3. Confirm pre-populated data; and
4. Extract new data to update the clinical recommendations

Familiarity with the [\$apply operation](OperationDefinition-cpg-plandefinition-apply.html), [CPG Case Feature Definition](StructureDefinition-cpg-casefeaturedefinition.html), and [SDC form population and extraction](https://hl7.org/fhir/uv/sdc/) are pre-requisites to understanding this process.

### PlanDefinition $apply with questionnaire

Questionnaire generation, population, and extraction is enabled for CPG Apply based on the presence of case feature definition as action.input. The plan definition is processed as follows:

1. When calling planDefinition/\$apply, if the plan includes action.input where the profile is a case feature definition (StructureDefinition), use [planDefinition/\$questionnaire](#plandefinitionquestionnaire) to generate a single Questionnaire. This process involves recursing over nested plan definitions to capture all case features in the questionnaire.

<!-- > Note: Steps 1 & 2 represent planDefinition/\$questionnaire processing but are broken down to simplify the higher level process

1. For each case feature definition referenced from PlanDefinition action.input, call [StructureDefinition/$questionnaire](https://hl7.org/fhir/R4/structuredefinition-operation-questionnaire.html) in minimal mode (coreOnly=true). Recurse over nested plan definitions to include all case features.


2. Add each set of questions from step 1 (each corresponding to a case feature) as group items in a questionnaire to produce a single questionnaire. The questionnaire should conform to [SDC Populatable Questionnaire - Expression](http://hl7.org/fhir/uv/sdc/StructureDefinition/sdc-questionnaire-pop-exp) and [SDC Extractable Questionnaire - Definition](http://hl7.org/fhir/uv/sdc/StructureDefinition/sdc-questionnaire-extr-defn) and should align with the expected output of [Questionnaire/$assemble](https://hl7.org/fhir/uv/sdc/OperationDefinition-Questionnaire-assemble.html), although the assembly process may differ. -->

2. Build a pre-populated QuestionnaireResponse containing the Questionnaire from Step 1 by calling [questionnaire/$populate](http://hl7.org/fhir/uv/sdc/OperationDefinition/Questionnaire-populate) using [SDC expression based population](https://hl7.org/fhir/uv/sdc/populate.html#exp-pop).

3. Render the QuestionnaireResponse to the user and pause for user input to either

   1. Change the QuestionnaireResponse and proceed to Steps 4 and 5; Or

   2. Select recommendations from the RequestGroup and end the apply cycle

4. If the QuestionnaireResponse is updated, call [QuestionnaireResponse/$extract](https://hl7.org/fhir/uv/sdc/OperationDefinition-QuestionnaireResponse-extract.html) using [SDC definition based extraction](https://hl7.org/fhir/uv/sdc/extraction.html#definition-extract) to create new resources based on QuestionnaireResponse from Step 3.

5. If there are new resources from Step 4, pass to the context and call [PlanDefinition/$apply](OperationDefinition-cpg-plandefinition-apply.html). The cycle repeats.

<img src="interactive-cds.png" alt="Interactive CDS Overview" width="700"/>

#### Interactive CDS as an Adaptive Process

As outlined, the apply with questionnaire cycle is intended to repeat anytime new data is extracted from a QuestionnaireResponse. As new data is obtained, new questions are potentially displayed depending on applicable branches of the pathway (applicable actions). Conceptually this is similar to the [SDC Adaptive Forms $next-question operation](http://hl7.org/fhir/uv/sdc/OperationDefinition/Questionnaire-next-question) where a questionnaire is dynamic depending on prior user input. However, in interactive CDS, the $apply operation is called to determine appropriate questions.

### Questionnaire Generation Processing Semantics

The \$questionnaire operation is used to generate a questionnaire when running \$apply. Questionnaire can be called on StructureDefinition or PlanDefinition.

#### StructureDefinition/$questionnaire

See [CPG $questionnaire operation](OperationDefinition-cpg-structureDefinition-questionnaire.html). The core operation is extended in CPG to support the parameter "coreOnly". If true, elements from the structure definition should be processed if:

1. The element is a part of the differential;
2. The element is a part of the snapshot and has a cardinality of at least 1..\* (min >1). Nested child elements with min > 1 should also be included if parent has min > 1;
3. The element is not a fixed value (fixed[x] or pattern[x]). Fixed elements are not neccessary on questionnaires inteded for definition based extraction.

Optionally, the parameter "supportedOnly" may be supplied. If true, the above applies only to elements with must support flags.

The goal of core only mode is to process only the elements required for definition based extraction. See [Authoring Guidance](#authoring-guidance) for best practices on authoring case feature definitions intended for form generation and extraction.

<style>
  table, th, td {
    border: 1px solid gray
  }
</style>

| Element Definition                                    | Questionnaire Item                                                     | notes                                                                                                                                                             |
| ----------------------------------------------------- | ---------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| extension[sdc-questionnaire-definitionExtractValue]   | sets extension[sdc-questionnaire-definitionExtractValue] on group item | see [Conformance with expression based population and definition based extraction](#conformance-with-expression-based-population-and-definition-based-extraction) |
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

- If the element includes the [SDC definition extract value extension](https://build.fhir.org/ig/HL7/sdc/StructureDefinition/sdc-questionnaire-definitionExtractValue), it is not necessary to create a questionnaire item. Instead, carry the extension over to the root item with type 'group'. See [details on populate and extract conformance below](#conformance-with-expression-based-population-and-definition-based-extractionconformance).

- Otherwise, process a new child item as follows

  - If CPG case featureExpression is present, set the [SDC initial expression extension](http://hl7.org/fhir/uv/sdc/StructureDefinition/sdc-questionnaire-initialExpression).

  - QuestionnaireItem.linkId &rarr; generate some unique id

  - QuestionnaireItem.definition &rarr; "{structureDefinition.url}#{full element path}", where:

    - "full element path" is path unless the path is a choice type (e.g. 'Observation.value[x]')
    - "full element path" is path with `[x]` replaced with type.code

  - QuestionnaireItem.code &rarr; Not used

  - QuestionnaireItem.prefix &rarr; Not used

  - QuestionnaireItem.text in order of preference &rarr;

    - Element short description;
    - Element label; or
    - "Stringify" the path

  - QuestionnaireItem.type (should always be a primitive type) &rarr;

    - If the element type is specified in the differential, map to Questionnaire.type
    - If the element type is not specified in the differential, use the snapshot type and map to Questionnaire.type
    - If type code, treat as a coding with type 'choice' (note: during $extract need to map this type back to code)
    - For a more detailed mapping of primitive and complex data types, see [ElementDefinition Mappings](#mapping-elementdefinition-data-types-to-questionnaire-items)

  - QuestionnaireItem.required &rarr; if (element.min > 0)

  - QuestionnaireItem.repeats &rarr; if (element.max > 1)

  - QuestionnaireItem.readOnly &rarr; Context from the corresponding data-requirement or default[x] (???)

  - QuestionnaireItem.maxLength &rarr; element.maxLength (if type is a string)

  - QuestionnaireItem.answerOption &rarr; expanded value set binding <!-- How should example binding be handled? open choice? -->

    <!-- to do: how to handle [questionnaire-unit](http://hl7.org/fhir/R4/extension-questionnaire-unit.html)-->

    <!-- to do: how to handle sliced elements-->

##### Conformance with expression based population and definition based extraction

See [SDC expression based population](https://hl7.org/fhir/uv/sdc/populate.html#exp-pop) and [SDC definition based extraction](https://hl7.org/fhir/uv/sdc/extraction.html#definition-extract)

To conform to \$populate and \$extract:

- At the root of the questionnaire, include extension [questionnaire-launchContext](https://hl7.org/fhir/uv/sdc/StructureDefinition-sdc-questionnaire-launchContext.html) for the in context subject (most often Patient), encounter, etc

- At the root item with type 'group'

  - Include the [SDC definition extract extension](https://build.fhir.org/ig/HL7/sdc/StructureDefinition/sdc-questionnaire-definitionExtract). Set extension[definition].valueCanonical to the canonical of the SD.

  - Carry over any [SDC definition extract value extension](https://build.fhir.org/ig/HL7/sdc/StructureDefinition/sdc-questionnaire-definitionExtractValue) from the structure definition.

  - If CPG featureExpression is present on the SD

    - Add the [SDC item population context extension](http://hl7.org/fhir/uv/sdc/StructureDefinition/sdc-questionnaire-itemPopulationContext) set to the CPG featureExpression;

    - For each child item, include the [questionnaire-initialExpression](https://hl7.org/fhir/uv/sdc/StructureDefinition-sdc-questionnaire-initialExpression.html) extension use the population context

##### Mapping ElementDefinition data types to Questionnaire Items

Allowed data types beteween element definition and questionnaire items differ where element definition allows for complex data types and questionnaire item is restricted to primitive types, Quantity, Reference, Attachement, and Coding. The data types can be mapped between StructureDefinition and Questionnaire as outlined in the table below.

| FHIR Primitive Data Type | Questionnaire.item.type Code | QuestionnaireResponse.item.answerValue[x] Data Type | Notes                                                            |
| ------------------------ | ---------------------------- | --------------------------------------------------- | ---------------------------------------------------------------- |
| base64Binary             | string                       | string                                              |                                                                  |
| boolean                  | boolean                      | boolean                                             |                                                                  |
| canonical                | url                          | uri                                                 |                                                                  |
| code                     | choice                       | coding                                              | During $extract, this needs to map back from coding to code      |
| date                     | date                         | date                                                |                                                                  |
| dateTime                 | dateTime                     | dateTime                                            |                                                                  |
| decimal                  | decimal                      | decimal                                             |                                                                  |
| id                       | string                       | string                                              |                                                                  |
| instant                  | dateTime                     | dateTime                                            |                                                                  |
| integer                  | integer                      | integer                                             |                                                                  |
| integer64                | integer                      | integer                                             |                                                                  |
| markdown                 | string                       | string                                              |                                                                  |
| oid                      | string                       | uri                                                 |                                                                  |
| positiveInt              | integer                      | integer                                             |                                                                  |
| string                   | string                       | string                                              |                                                                  |
| time                     | time                         | time                                                |                                                                  |
| unsignedInt              | integer                      | integer                                             |                                                                  |
| uri                      | url or string                | uri                                                 | Check that the URI is a valid URL, if not it should be a string? |
| url                      | url                          | uri                                                 |                                                                  |
| uuid                     | string                       | uri                                                 |                                                                  |

| Other Data Types | QuestionnaireItem.type Code                                     | QuestionnaireResponse.item.answerValue[x] Data Type                  | Notes                                                                                                                                                                                                     |
| ---------------- | --------------------------------------------------------------- | -------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| coding           | choice                                                          | coding                                                               |                                                                                                                                                                                                           |
| codeableConcept  | subgroup with items of type choice (coding) and string (text)?? | initialValueCoding; and/or<br>initialValueString (to represent text) |                                                                                                                                                                                                           |
| quantity         | quantity                                                        | quanitity                                                            | Extension [https://hl7.org/fhir/extensions/StructureDefinition-questionnaire-unit.html](https://hl7.org/fhir/extensions/StructureDefinition-questionnaire-unit.html) can be used to capture specific unit |
| reference        | reference                                                       | reference                                                            |                                                                                                                                                                                                           |
| attachment       | attachment                                                      | attachment                                                           |                                                                                                                                                                                                           |

For non-primitive, complex data types, $questionnaire should be applied to the SD of the data type and returned as a subgroup of questionnaire items. An example of the [Range data type](https://www.hl7.org/fhir/datatypes.html#Range) represented as a group of questionnaire items follows.

```
{
  "linkId": "Range",
  "definition": "http://example.org/StructureDefinition/ExampleObservation#Observation.value[x]:valueRange",
  "text": "Actual result",
  "type": "group",
  "item": [
    {
      "linkId": "Range.low",
      "definition": "http://example.org/StructureDefinition/ExamleObservation#Observation.value[x]:valueRange.low",
      "text": "Low limit",
      "type": "quantity"
    },
    {
      "linkId": "Range.high",
      "definition": "http://example.org/StructureDefinition/ExampleObservation#Observation.value[x]:valueRange.high",
      "text": "High limit",
      "type": "quantity"
    }
  ]
}
```

#### PlanDefinition/$questionnaire

See [CPG plan definition $questionnaire operation](OperationDefinition-cpg-planDefinition-questionnaire.html).

PlanDefinition/\$questionnaire uses the same principles and methodology as StructureDefinition/\$questionnaire, but is generated from multiple StructureDefinitions. These are case feature definitions referenced from PlanDefinition action.input.

The PlanDefinition is processed as follows:

1. Find all planDefinition.action.input elements where a case feature is referenced. If the plan definition includes action.definitionCanonical with a reference to another plan definition, recurse over the nested planDefinition.action.input elements.

2. Using the processing semantics for structureDefintion/\$apply, for each case feature identified from the PlanDefinition:

   1. Generate a group of questionnaire items on the target questionnaire; or

   2. To leverage [Questionnaire/$assemble](https://hl7.org/fhir/uv/sdc/OperationDefinition-Questionnaire-assemble.html), generate an individual questionnaire for each case feature. Then call \$assemble to generate a single questionnaire. See [SDC modular questionnaires](https://hl7.org/fhir/uv/sdc/modular.html#modular) for implementation details.

The questionnaire should conform to [SDC Populatable Questionnaire - Expression](http://hl7.org/fhir/uv/sdc/StructureDefinition/sdc-questionnaire-pop-exp) and [SDC Extractable Questionnaire - Definition](http://hl7.org/fhir/uv/sdc/StructureDefinition/sdc-questionnaire-extr-defn) and should align with the expected output of [Questionnaire/$assemble](https://hl7.org/fhir/uv/sdc/OperationDefinition-Questionnaire-assemble.html), although the assembly process may differ.

### Authoring Guidance

To support form generation, population, and extraction, case features should be authored with compatibility in mind:

- If unable to support the use of snapshot when mapping questionnaire items from element definitions, required elements should be intentionally authored as a part of the structure definition differential and include the elementDefinition.type.

- [Case feature expression](StructureDefinition-cpg-featureExpression.html) may be used on case feature to support questionnaire pre-population through

  1. Inferencing rules; and/or
  2. Assertion rules (existing case feature)

- In the case of an element that should be set based on questionnaire context (i.e. subject of the questionnaire), include the [SDC Questionnaire Definition Extract Value Extension](https://build.fhir.org/ig/HL7/sdc/StructureDefinition/sdc-questionnaire-definitionExtractValue) on the element.

<!-- TODO: Config/specialization here
Consider:
- Different institutations/implementations may want variation here?
  - Current approach is to allow authors to specify this in the action.input
  - How do we support site-specific configuration
    - Document patterns of support, currently at least configuration options (see opioid mme for examples)
    - Also support "specialization" patterns for changing PlanDefinitions/deriving new PlanDefinition
 -->