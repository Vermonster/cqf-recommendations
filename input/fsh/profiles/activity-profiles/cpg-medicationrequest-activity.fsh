Profile: CPGMedicationRequestActivity
Parent: $cpg-computableactivity
Id: cpg-medicationrequestactivity
Title: "CPG Medication Request Activity"
Description: "Definition of a recommendation for a specific medication as part of a computable clinical practice guideline"
* insert StructureDefinitionMetadata(cpg-medicationrequestactivity)
* kind 1..1 MS
* kind only code
* kind = #MedicationRequest (exactly)
* profile 1..1 MS
* profile only canonical
* profile = "http://hl7.org/fhir/uv/cpg/StructureDefinition/cpg-medicationrequest" (exactly)
  * ^short = "At least a CPG MedicationRequest"
  * ^definition = "The profile that the resulting medication request must conform to; at least a CPGMedicationRequest, though the activity definition may introduce further constraints."
* intent 1..1 MS
* intent only code
* intent = #proposal (exactly)
* doNotPerform 1..1 MS



