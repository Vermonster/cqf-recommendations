Instance: request-dcm-scenario2
InstanceOf: Task
Usage: #example
* instantiatesCanonical = Canonical(activity-example-documentmedication-ad)
* status = #draft
* intent = #proposal
* code = $cpg-activity-type-cs#document-medication "Document a medication"
* for = Reference(dcm-scenario2-patient)
* input
  * type = $cpg-activity-type-cs#order-medication "Order a medication"
  * valueReference = Reference(dcm-scenario2)