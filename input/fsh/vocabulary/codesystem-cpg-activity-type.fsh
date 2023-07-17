CodeSystem: CPGActivityType
Id: cpg-activity-type
Title: "CPG Activity Type Codes"
Description: "A type of activity that can be performed as part of the delivery of guideline-based care."
* insert CodeSystemMetadata(cpg-activity-type, CodeSystem)
* #send-message "Send a message" "The activity of communicating a particular message to a patient"
* #collect-information "Collect information" "The task of collecting information from a patient using a specified questionnaire"
* #order-medication "Order a medication" "The task of ordering or prescribing a particular medication to a patient"
* #dispense-medication "Dispense a medication" "The task of dispensing a particular medication to a patient"
* #administer-medication "Administer a medication" "The task of administering a particular medication to a patient"
* #document-medication "Document a medication" "The task of documenting use of a particular medication by a patient"
* #recommend-immunization "Recommend an immunization" "The task of recommending a particular immunization for a patient"
* #order-service "Order a service" "The activity of ordering or performing a particular service"
* #enrollment "Enroll in a pathway or strategy" "The activity of enrolling or unenrolling a patient in a particular pathway or strategy"
* #generate-report "Generate a metric or case report" "The activity of generating a metric, measure, or case report"
* #propose-diagnosis "Propose a diagnosis" "The activity of proposing a particular diagnosis"
* #record-detected-issue "Record a detected issue" "The activity of reporting or recording a specific detected issue"
* #record-inference "Record an inference" "The activity of making and reporting or recording a particular inference"
* #report-flag "Report a flag" "The activity of reporting or recording a particular flag"