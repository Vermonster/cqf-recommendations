Instance: activity-example-donotcollectinformation-pd
InstanceOf: PlanDefinition
Usage: #example
Title: "Activity Example Do Not Collect Information PD"
* description = "Example Plan Definition for a recommendation not to collect information"
* insert PDRecommendationMetadata(activity-example-donotcollectinformation-pd)
* name = "ActivityExampleDoNotCollectInformationPD"
* type = $plan-definition-type#eca-rule
* library = Canonical(donotcollectinformation-library)
* action
  * title = "Collect date of patient last visit"
  * condition
    * kind = #applicability
    * expression
      * language = #text/cql-identifier
      * expression = "Is Recommendation Applicable"
  * type = $action-type#create
  * definitionCanonical = Canonical(activity-example-donotcollectinformation-ad)