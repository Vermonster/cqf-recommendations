Instance: sm-scenario6
InstanceOf: Communication
Usage: #example
* status = #not-done
* statusReason.text = "Patient refused"
* subject = Reference(Patient/sm-scenario6-patient)
* payload.contentString = "Hello!"
* recipient = Reference(Patient/sm-scenario6-patient)