/**
1. Add minimal or required only parameter
requiredOnly is not fitting bc the elements are not necessarily min=1
2. What about CRMI parameters?
*/
Instance: cpg-structureDefinition-questionnaire
InstanceOf: OperationDefinition
Usage: #definition
Title: "CPG StructureDefinition Questionnaire"
Description: """
Generates a Questionnaire instance  based on a specified StructureDefinition, creating questions for each core element or extension elements found in the Structure Definition.
"""
* insert OperationDefinitionMetadata(cpg-structureDefinition-questionnaire)
* insert OperationExtensions(5)
* name = "CPGStructureDefinitionQuestionnaire"
* experimental = false
* code = #questionnaire
* comment = """
 If the operation is not called at the instance level, one of the *identifier*, *profile* or *url* 'in' parameters must be provided. If more than one is specified, servers may raise an error or may resolve with the parameter of their choice. If called at the instance level, these parameters will be ignored. The response will contain a [Questionnaire](https://hl7.org/fhir/R4/questionnaire.html) instance based on the specified [StructureDefinition](https://hl7.org/fhir/R4/structuredefinition.html) and/or an [OperationOutcome](https://hl7.org/fhir/R4/operationoutcome.html) resource with errors or warnings.  Nested groups are used to handle complex structures and data types.  If the 'supportedOnly' parameter is set to true, only those elements marked as \"must support\" will be included. ***If the 'differentialOnly' parameter is set to true, only elements from the differential will be included, and snapshot elements will be excluded.***  \n\nSee [Questionnaire Processing Semantics](interactive-cds.html#questionnaire-generation-processing-semantics) for further details.
"""
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
  * documentation = "The StructureDefinition is provided directly as part of the request. Servers may choose not to accept profiles in this fashion"
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
  * name = #coreElementsOnly
  * use = #in
  * min = 0
  * max = "1"
  * documentation = "If true, the questionnaire will only core elements from the StructureDefinition."
  * type = #boolean
* parameter[+]
  * name = #artifactEndpointConfiguration
  * min = 0
  * max = "*"
  * use = #in
  * documentation = """
Configuration information to resolve canonical artifacts

Processing Semantics:

Create a canonical-like reference (e.g.
`{canonical.url}|{canonical.version}` or similar extensions for non-canonical artifacts).

* Given a single `artifactEndpointConfiguration`
  * When `artifactRoute` is present
    * And `artifactRoute` *starts with* canonical or artifact reference
    * Then attempt to resolve with `endpointUri` or `endpoint`
  * When `artifactRoute` is not present
    * Then attempt to resolve with `endpointUri` or `endpoint`
* Given multiple `artifactEndpointConfiguration`s
  * Then rank order each configuration (see below)
  * And attempt to resolve with `endpointUri` or `endpoint` in order until resolved

Rank each `artifactEndpointConfiguration` such that:
* if `artifactRoute` is present *and* `artifactRoute` *starts with* canonical or artifact reference: rank based on number of matching characters
* if `artifactRoute` is *not* present: include but rank lower

NOTE: For evenly ranked `artifactEndpointConfiguration`s, order as defined in the
OperationDefinition.
"""
  * part[+]
    * name = #artifactRoute
    * min = 0
    * max = "1"
    * use = #in
    * type = #uri
    * documentation = "An optional route used to determine whether this endpoint is expected to be able to resolve artifacts that match the route (i.e. start with the route, up to and including the entire url)"
  * part[+]
    * name = #endpointUri
    * min = 0
    * max = "1"
    * use = #in
    * type = #uri
    * documentation = "The URI of the endpoint, exclusive with the `endpoint` parameter"
  * part[+]
    * name = #endpoint
    * min = 0
    * max = "1"
    * use = #in
    * type = #Endpoint
    * documentation = "An Endpoint resource describing the endpoint, exclusive with the `endpointUri` parameter"
* parameter[+]
  * documentation = "An endpoint to use to access terminology (i.e. valuesets, codesystems, and membership testing) referenced by the PlanDefinition. If no terminology endpoint is supplied, the evaluation will attempt to use the server on which the operation is being performed as the terminology server."
  * max = "1"
  * min = 0
  * name = #terminologyEndpoint
  * type = #Endpoint
  * use = #in
* parameter[+]
  * name = #return
  * use = #out
  * min = 1
  * max = "1"
  * documentation = "The questionnaire form generated based on the StructureDefinition."
  * type = #Questionnaire