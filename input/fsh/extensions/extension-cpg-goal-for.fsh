Extension: CPGGoalFor
Id: cpg-goalFor
Title: "CPG Goal For"
Description: "The URL of the PlanDefinition (recommendation, strategy, or pathway) that the goal is related to, or defined in support of."
* insert DefinitionMetadata(cpg-goalFor, StructureDefinition)
* ^context.type = #element
* ^context.expression = "Goal"
* . 0..*
  * ^short = "Goal For?"
  * ^definition = "The URL of the PlanDefinition (recommendation, strategy, or pathway) that the goal is related to, or defined in support of."
* url only uri
* url = "http://hl7.org/fhir/uv/cpg/StructureDefinition/cpg-goalFor" (exactly)
* value[x] only canonical
  * ^type.targetProfile = "http://hl7.org/fhir/uv/cpg/StructureDefinition/cpg-shareableplandefinition"