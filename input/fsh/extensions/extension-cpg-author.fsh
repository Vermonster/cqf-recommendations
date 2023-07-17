Extension: CPGAuthor
Id: cpg-author
Title: "CPG Author"
Description: "Specifies the author of the content."
* insert DefinitionMetadata(cpg-author, StructureDefinition)
* ^context.type = #element
* ^context.expression = "Resource"
* . 0..*
  * ^short = "Who authored the content"
  * ^definition = "Specifies the author of the content."
* url only uri
* url = "http://hl7.org/fhir/uv/cpg/StructureDefinition/cpg-author" (exactly)
* value[x] only ContactDetail