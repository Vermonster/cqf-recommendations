Instance: chf-scenario1-bodyweight2-observation
InstanceOf: CHFBodyWeight
Usage: #example
Description: "CHF Scenario One"
* extension[+]
  * url = Canonical(cpg-instantiatesCaseFeature)
  * valueCanonical = Canonical(chf-bodyweight)
* extension[+]
  * url = Canonical(cpg-caseFeatureType)
  * valueCode = #asserted
* status = #final
* category[VSCat] = $observation-category#vital-signs
* code = $loinc#29463-7
* effectiveDateTime = "2019-02-01T07:00:00Z"
* issued = "2019-02-01T07:00:00Z"
* subject = Reference(chf-scenario1-patient)
* encounter = Reference(chf-scenario1-encounter)
* performer = Reference(chf-scenario1-practitionerrole)
* valueQuantity = 95.4 'kg' "kg"