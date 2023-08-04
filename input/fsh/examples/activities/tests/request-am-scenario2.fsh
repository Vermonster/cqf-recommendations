Instance: request-am-scenario2
InstanceOf: Task
Usage: #example
* instantiatesCanonical = Canonical(activity-example-administermedication-ad)
* status = #draft
* intent = #proposal
* code = $cpg-activity-type-cs#administer-medication "Administer a medication"
* for = Reference(am-scenario2-patient)
* input
  * type = $cpg-activity-type-cs#administer-medication "Administer a medication"
  * valueReference = Reference(am-scenario2)