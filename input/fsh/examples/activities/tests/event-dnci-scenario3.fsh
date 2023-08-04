Instance: event-dnci-scenario3
InstanceOf: Task
Usage: #example
* instantiatesCanonical = Canonical(activity-example-collectinformation-ad)
* status = #in-progress
* intent = #order
* code = $cpg-activity-type-cs#collect-information "Collect information"
* for = Reference(dnci-scenario3-patient)
* input
  * type = $cpg-activity-type-cs#collect-information "Collect information"
  * valueCanonical = Canonical(activity-example-collectinformation-questionnaire)