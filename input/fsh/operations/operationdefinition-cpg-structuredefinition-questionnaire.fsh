/**
1. Add minimal or required only parameter
requiredOnly is not fitting bc the elements are not necessarily min=1
2. What about CRMI parameters?
*/
Instance: cpg-structureDefinition-questionnaire
InstanceOf: OperationDefinition
Usage: #definition
Title: "CPG StructureDefinition Questionnaire"
Description: "Generates a [Questionnaire](questionnaire.html) instance  based on a specified [StructureDefinition](structuredefinition.html), creating questions for each core element or extension element found in the [StructureDefinition](structuredefinition.html).    \n\nIf the operation is not called at the instance level, one of the *identifier*, *profile* or *url* 'in' parameters must be provided. If more than one is specified, servers may raise an error or may resolve with the parameter of their choice. If called at the instance level, these parameters will be ignored. The response will contain a [Questionnaire](questionnaire.html) instance based on the specified [StructureDefinition](structuredefinition.html) and/or an [OperationOutcome](operationoutcome.html) resource with errors or warnings.  Nested groups are used to handle complex structures and data types.  If the 'supportedOnly' parameter is set to true, only those elements marked as \"must support\" will be included. ***If the 'differentialOnly' parameter is set to true, only elements from the differential will be included, and snapshot elements will be excluded.***  \n\nThis operation is intended to enable auto-generation of simple interfaces for arbitrary profiles.  The 'questionnaire' approach to data entry has limitations that will make it less optimal than custom-defined interfaces.  However, this function may be useful for simple applications or for systems that wish to support \"non-core\" resources with minimal development effort."
* insert OperationDefinitionMetadata(cpg-structureDefinition-questionnaire)
* insert OperationExtensions(5)
* name = "CPGStructureDefinitionQuestionnaire"
* experimental = false
* code = #questionnaire
* comment = "**Open Issue**: Ideally, extensions should be populated in the generated [Questionnaire](questionnaire.html) that will support taking [QuestionnaireResponse](questionnaireresponse.html) resources generated from the Questionnaire and turning them back into the appropriate resources."
* resource = #StructureDefinition
* system = false
* type = true
* instance = true
* parameter[0]
  * name = #identifier
  * use = #in
  * min = 0
  * max = "1"
  * documentation = "A logical identifier (i.e. 'StructureDefinition.identifier''). The server must know the StructureDefinition or be able to retrieve it from other known repositories."
  * type = #Identifier
* parameter[+]
  * name = #profile
  * use = #in
  * min = 0
  * max = "1"
  * documentation = "The [StructureDefinition](structuredefinition.html) is provided directly as part of the request. Servers may choose not to accept profiles in this fashion"
  * type = #StructureDefinition
* parameter[+]
  * name = #url
  * use = #in
  // * scope = "type"
  * min = 0
  * max = "1"
  * documentation = "The StructureDefinition's official URL (i.e. 'StructureDefinition.url'). The server must know the StructureDefinition or be able to retrieve it from other known repositories."
  * type = #canonical
  * targetProfile = "http://hl7.org/fhir/StructureDefinition/StructureDefinition"
* parameter[+]
  * name = #supportedOnly
  * use = #in
  * min = 0
  * max = "1"
  * documentation = "If true, the questionnaire will only include those elements marked as \"mustSupport='true'\" in the StructureDefinition."
  * type = #boolean
* parameter[+]
  * name = #differentialOnly
  * use = #in
  * min = 0
  * max = "1"
  * documentation = "If true, the questionnaire will only include those differential elements in the StructureDefinition."
  * type = #boolean
* parameter[+]
  * name = #return
  * use = #out
  * min = 1
  * max = "1"
  * documentation = "The questionnaire form generated based on the StructureDefinition."
  * type = #Questionnaire