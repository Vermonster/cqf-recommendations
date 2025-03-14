Interactive CDS is a process whereby the clinician facing user interface prompts for required data ([CPG Case Feature]())  via a questionnaire and questionnaire response in order to evaluate the applicability of clinical guideline recommendations ([CPG Plan Definition]()).

### PlanDefinition $apply with questionnaire generation

Questionnaire generation may be enabled for PlanDefinition/$apply to elicit user feedback on required data elements as follows:

1. For each PlanDefinition with action.input, call [StructureDefinition/$questionnaire](https://hl7.org/fhir/R4/structuredefinition-operation-questionnaire.html) in minimal mode (differentialOnly=true)

2. For each set of questions generated in step 1, add these as group items to the questionnaire to produce a single questionnaire. The process should conceptually align with [Questionnaire/$assemble](https://hl7.org/fhir/uv/sdc/OperationDefinition-Questionnaire-assemble.html) and conform to [SDC Extractable Questionnaire](http://hl7.org/fhir/uv/sdc/StructureDefinition/sdc-questionnaire-extr-defn), although the methodology may differ.

3. To build a pre-populated QuestionnaireResponse containing the Questionnaire from Step 2, call [Questionnaire/$populate](https://hl7.org/fhir/uv/sdc/OperationDefinition-Questionnaire-populate.html)

4. Pause for user input to either

   1. Change the QuestionnaireResponse and proceed to Steps 3 and 4; Or

   2. Select recommendations from the RequestGroup and end they apply cycle

5. If the QuestionnaireResponse is updated, call [QuestionnaireResponse/$extract](https://hl7.org/fhir/uv/sdc/OperationDefinition-QuestionnaireResponse-extract.html) to create new resources based on QuestionnaireResponse from Steps 3 and 4

6. If there are new resources from Step 5, pass to the context and call [PlanDefinition/$apply](https://build.fhir.org/ig/HL7/cqf-recommendations/OperationDefinition-cpg-plandefinition-apply.html). The cycle repeats.

In this way, $questionnaire is used with $apply and existing SDC operations to

1. Prompt users for required data;
2. Pre-populate answers based on documented case features and/or inferencing rules;
3. Confirm pre-populated data;
4. Extract new data; and
5. Return the latest recommendations

### Questionnaire Processing Semantics

To enable questionnaire generation based on CPG Case Features, $questionnaire can be called with StructureDefinition and PlanDefinition.

#### StructureDefinition/$questionnaire

See [core $questionnaire operation](https://hl7.org/fhir/R4/structuredefinition-operation-questionnaire.html)

The core operation is extended in CPG to support the parameter 'differentialOnly'. In this way, only the elements that are necessary for form data extraction will be generated as questionnaire items. See [Authoring Guidance](#authoring-guidance).

<!-- What if must support and differential only are true ? -->

Optionally, the parameter "supportedOnly" may be supplied. If true, the above applies only to elements with must support flags.

| elementDefinition                                     | questionnaireItem                                                                                                                              | notes                                                                                                                                                             |
| ----------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| pattern[x]                                            | sets initial[x], hidden true                                                                                                                   | Because questionnaire.item.initial.value[x] is a subset of pattern[x], we have rules to coerce                                                                    |
| fixed[x]                                              | sets initial[x], hidden true                                                                                                                   | Because questionnaire.item.initial.value[x] is a subset of fixed[x], we have rules to coerce                                                                      |
| defaultValue[x]                                       | sets initial[x], hidden false                                                                                                                  |                                                                                                                                                                   |
| CPG featureExpression                                 | sets [questionnaire-initialExpression](https://hl7.org/fhir/uv/sdc/StructureDefinition-sdc-questionnaire-initialExpression.html), hidden false | see [Conformance with expression based population and definition based extraction](#conformance-with-expression-based-population-and-definition-based-extraction) |
| {structureDefinition.url}#{element.path}              | definition                                                                                                                                     | for choice type paths, replace [x] with element type.code[0]                                                                                                      |
| short description; element label; or stringified path | text                                                                                                                                           |                                                                                                                                                                   |
| type                                                  | type                                                                                                                                           | see [ElementDefinition Mappings](#mapping-elementdefinition-data-types-to-questionnaire-items)                                                                    |
| min > 0                                               | required                                                                                                                                       |                                                                                                                                                                   |
| max > 1                                               | repeats                                                                                                                                        |                                                                                                                                                                   |
| maxLength                                             | maxLength                                                                                                                                      | apply if type = string                                                                                                                                            |
| binding.valueSet                                      | expanded valueSet used as answerOption, set type as 'choice'                                                                                   |                                                                                                                                                                   |
| ??                                                    | readOnly                                                                                                                                       |                                                                                                                                                                   |

Process elements from the structure definition resource:

- For each element to process, create a questionnaire item
  - If the element has pattern[x] or fixed[x] make the item hidden and set initial[x]
  - Otherwise, make the item visible
  - If CPG case featureExpression returns a value for the element, set initialExpression (see [Conformance with expression based population and definition based extraction](#conformance-with-expression-based-population-and-definition-based-extraction)); else if the element has defaultValue[x], set initial[x]
  - For the rest of questionnaire item properties:
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
      - If of type code, treat as a coding with type 'choice'(note: during $extract need to map this type back to code)
      - For a more detailed mapping of primitive and complex data types, see [ElementDefinition Mappings](#mapping-elementdefinition-data-types-to-questionnaire-items)
    - QuestionnaireItem.required => if (element.min > 0)
    - QuestionnaireItem.repeats => if (element.max > 1)
    - QuestionnaireItem.readOnly => Context from the corresponding data-requirement or default[x] (???)
    - QuestionnaireItem.maxLength => element.maxLength (if type is a string)
    - QuestionnaireItem.answerOption => expanded value set binding <!-- How should example binding be handled? open choice? -->
- Ideally, the snapshot element will be used as a fallback for properties missing on differential elements. <!-- How should properties like "type" be handled, where the snapshot element definition may include multiple types -->

##### Conformance with expression based population and definition based extraction

See [SDC expression based population](https://build.fhir.org/ig/HL7/sdc/populate.html#expression-based-population) and [SDC definition based extraction](https://hl7.org/fhir/uv/sdc/extraction.html#definition-based-extraction)

To conform to $populate and \$extract, the questionnaire should:

- Include extension [questionnaire-launchContext](https://hl7.org/fhir/uv/sdc/StructureDefinition-sdc-questionnaire-launchContext.html) on the questionnaire for the in context subject (most often Patient)
- If the extension [CPG featureExpression](https://hl7.org/fhir/uv/cpg/StructureDefinition-cpg-featureExpression.html), set [questionnaire-itemPopulationContext](https://build.fhir.org/ig/HL7/sdc/StructureDefinition-sdc-questionnaire-itemPopulationContext.html) on the root item to the featureExpression.valueExpression
- For each element where there is a [CPG featureExpression](https://hl7.org/fhir/uv/cpg/StructureDefinition-cpg-featureExpression.html) value and absence of fixed[x] and pattern[x], set item [questionnaire-initialExpression](https://hl7.org/fhir/uv/sdc/StructureDefinition-sdc-questionnaire-initialExpression.html) extension expression to element path as a context variable. The item should be visible. <!--Is this the best way to get the corresponding case feature property?-->

Note that initial[x] and initialExpression are mutually exclusive. These are set in order of preference:

1. If available, use fixed[x] and patter[x] to set initial[x]; else

2. If available, use CPG featureExpression to set initialExpression; else

3. If available, use default[x] to set initial[x]

##### Mapping ElementDefinition data types to Questionnaire Items

- See mappings of FHIR primitive types to QuestionnaireItem.initialValue[x] and QuestionnaireItem.type [here](https://docs.google.com/spreadsheets/d/1YmmW28fDX0VsSlQAVsK2p9bbkV3hxhxnUaUCiRKAL6M/edit?usp=sharing)
- For non-primitive, complex data types, $questionnaire should be applied to the SD of the data type and returned as a subgroup of questionnaire items
- See `./rangeQuestionnaireRepresentation` as an example questionnaire.item representation of the Range data type [Datatypes - FHIR v5.0.0](https://www.hl7.org/fhir/datatypes.html#Range)

#### PlanDefinition/$questionnaire

<!-- the output is an assembled quetionnaire, under the hood could follow scd assemble with modular questionnaires, but may also assemble group items as long as the output is a single questionnaire --- one options: , etc-->
See [SDC modular questionnaires](https://build.fhir.org/ig/HL7/sdc/modular.html#modular) for assembly details.

Multiple questionnaires may be generated if there is more than one PlanDefinition.action.input. These can be combined into a modular questionnaire which can then be assembled to create a single questionnaire. To conform with $assemble

- Create a modular questionnaire with extension [assemble-expectation](https://build.fhir.org/ig/HL7/sdc/StructureDefinition-sdc-questionnaire-assemble-expectation.html) set to code "assemble-root"

- For each questionnaire generated from PlanDefinition.action.input, add the [subQuestionnaire](https://build.fhir.org/ig/HL7/sdc/StructureDefinition-sdc-questionnaire-subQuestionnaire.html) extension

#### Authoring Guidance



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
