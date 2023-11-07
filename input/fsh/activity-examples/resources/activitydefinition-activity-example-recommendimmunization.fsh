Instance: activity-example-recommendimmunization-ad
InstanceOf: CPGImmunizationActivity
Usage: #example
* title = "Activity Example Recommend Immunization AD"
* insert KnowledgeArtifactADMetadata(activity-example-recommendimmunization-ad)
* description = "Example Activity Definition for a recommendation to provide an immunization"
* name = "ActivityExampleRecommendImmunizationAD"
* kind = #MedicationRequest
* profile = Canonical(CPGImmunizationRequest)
* code = $cpg-activity-type-cs#recommend-immunization "Recommend an immunization"
* intent = #proposal
* priority = #routine
* doNotPerform = false
* productCodeableConcept = $sct#14745005 "Hepatitis A vaccine"