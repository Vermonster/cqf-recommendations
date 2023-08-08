Instance: anc-recommendation-a2
InstanceOf: PlanDefinition
Usage: #example
* url = "http://fhir.org/guides/who/anc/PlanDefinition/Recommendation_A2"
* identifier
  * use = #official
  * value = "Recommendation_A2"
* version = "0.1.0"
* name = "Recommendation_A2"
* title = "PlanDefinition - WHO ANC Guideline Recommendation #A2"
* type = $plan-definition-type#eca-rule "ECA Rule"
* status = #draft
* experimental = true
* date = "2019-05-15"
* copyright = "© WHO 2019+."
* library = "http://fhir.org/guides/who/anc/Library/ANCRecommendationA2"
* action
  * title = "Iron and Folic Acid Supplementation"
  * textEquivalent = "Daily elemental iron should be increased to 120 mg until her Hb concentration rises to normal"
  * trigger
    * type = #named-event
    * name = "anc-contact"
  * condition
    * kind = #applicability
    * expression
      * language = #text/cql
      * expression = "Has Anemia"