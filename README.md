The goal is to make this repository run on the latest HAPI JPA server. I guess you might call that a reference implementation. 

I've started with the stock https://github.com/cqframework.hiv-cds.git and made a few changes. 

Borrow _updateCQFTooling.sh from https://github.com/cqframework.cqf-ccs.git because the instances in this project were pretty far behind. Then I changed the tooling version to 3.1.0 the latest. I also borrowed _refresh.sh from https://github.com/cqframework.cqf-ccs.git. I added an -elm option to the RefreshIG routine to make sure we get elm in the Libraries. 

Next a few changes in PlanDefinition/HelloHIVWorld. In the library attribute I added a version number to the library canonical. Next I changed all the action.condition.expression.language attributes to `text/cql-identifier`. Finally for the last dynamicValue I changed `Info` to `Patient Name` because there is no `Info` definition in teh CQL. Lastly I bumped the version to 1.0.1. Now
```
http://localhost:8080/fhir/PlanDefinition/plandefinition-HelloHIVWorld/$apply?subject=Patient/HIVPatient
```
runs without OperationOutcome errors. It doesn't produce a card on https://sandbox.cds-hooks.org/ and there's and error in the server logs 
```
PlanDefinitionProcessor [PlanDefinitionProcessor.java:796] DynamicValue expression Patient Name encountered exception: Expected a list with at most one element, but found a list with multiple elements.
```
but after that error the server log produces a card object.
```
{"cards": [
    {
      "summary": "Hello HIV World!",
      "source": {
        "label": "Info for those with HIV",
        "url": "https://www.cdc.gov/hiv/guidelines/testing.html"
      },
      "links": []
    }
  ]
}
```
I've run _updatePublisher.sh but I haven't run _refresh.sh yet. 
