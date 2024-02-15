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

Moving on to Screening. Posted bundles/plandefinition/Screening/Screening-bundle.json with one error. 
```
diagnostics": "HAPI-1094: Resource PractitionerRole/hiv-practitionerrole-example not found, specified in path: Patient.generalPractitioner"
```
Running  $apply against HighRiskPregnantPatient. It seems not all of the Screening bundle was loaded on the server. The PlanDefinition isn't there. PlanDefinition HIVScreening is. 

How many PlanDefinitions have we?

After fixing up the HIVScreening PlanDefinition there are multiple errors with missing libraries. There's a bundle/Screening/Screening-files/library-deps-Screening-bundle.json that I will load. 
```
curl -d "@bundles/plandefinition/Screening/Screening-files/library-deps-Screening-bundle.json" -H "Content-Type: application/json" -X POST http://localhost:8080/fhir 
```

It appears that the CQL content in the HIVDataElements Library in the  bundles/plandefinition/Screening/Screening-files/library-deps-Screening-bundle.json file does not match the CQL at input/cql/
HIVDataElements.cql. "Encounter Type is missing". I know because I manually decoded the file from the content attriibute of the Library. I wonder if the HIVScreening library that I already uploaded is up to date. Let's check. Those are OK. 

Now to run _refresh to update the bundles? Yes. Will the new library-deps bundle contain the updated HIVDataElements? I.e. will HIVDataElements define an "Encounter Type:" and match its twin in input/cql? It does not. What about the HIVDataElements Library of the bundles/plandefinition/Screening/Screening-bundle.json? No! 

It turns out (and makes sense) that the updated HIVDataElements.cql is in bundles/HIVScreening/HIVScreening-bundle.json and input/resources/library/HIVDataElements. 

I need these libraries in a hand-made bundle. Or not. Whatever I said before, the bundles/HIVScreening/HIVScreening-files/library-deps-HIVScreening-bundle.json is up to date at least WRT HIVDataElements. OK That's much better but it looks like I still need FHIRCommon. There's a repeating error in the plandefinition/HIVScreening/$apply operation.
```
Could not resolve identifier Active Condition in library FHIRCommon. 
```
As I look back in the project it appears that some of the FHIRCommon Library content elements contain `define "Active Condition"` and `define "Incctive Condition"` and some do not. As it stands in the current server implementation there are two historical FHIRCommon libraries, one with the active/inactive condition definitions and one without. Unfortunately they have the same version number (4.0.1). THe current version of FHIRCommon is 4.1.0. THe current version contains active/inactive condition definitions. The active/inactive condition definitions were added in 4/2021 but the version was not bumped until three commits later in 10/2021. Whatever you do, make sure it's the verion with active/inactive versions that gets loaded on the HAPI server. So I deleted the FHIRCommon Library, made a custom transaction bundle with just FHIRCommon and uploaded it thus: 
```
curl -d "@bundles/plandefinition/HIVScreening/HIVScreening-files/library-HIVScreening-FHIRcommon-bundle.json" -H "Content-Type: application/json" -X POST http://localhost:8080/fhir 
```
OK that addresses the active/inactive condition resolution error. Now a different error. 
```
"diagnostics": "Condition expression 'true' encountered exception: Could not resolve expression reference ''true'' in library 'HIVScreening'."
```
That probably refers to a line in the PlanDefinition which appears to aim to pass the value `true` as a boolean datatype in. Maybe it should be type `text/cql` and not `text/cql-identier`. Let's try that. That's solved. 

This [page](https://cds-hooks.hl7.org/2.0/) discusses the fields in CHD Hooks. (

>Each Card is described by the following attributes.

|Field |Optionality |Type |Description|
|---|---|---|---|
|uuid |OPTIONAL |string |Unique identifier of the card. MAY be used for auditing and logging cards and SHALL be included in any subsequent calls to the CDS service's feedback endpoint.|
|summary |REQUIRED |string |One-sentence, <140-character summary message for display to the user inside of this card.|
|detail |OPTIONAL |string |Optional detailed information to display; if provided MUST be represented in (GitHub Flavored) Markdown. (For non-urgent cards, the CDS Client MAY hide these details until the user clicks a link like "view more details...").|
|indicator |REQUIRED |string |Urgency/importance of what this card conveys. Allowed values, in order of increasing urgency, are: info, warning, critical. The CDS Client MAY use this field to help make UI display decisions such as sort order or coloring.|
|source |REQUIRED |object |Grouping structure for the Source of the information displayed on this card. The source should be the primary source of guidance for the decision support the card represents.|
|suggestions |OPTIONAL |array of Suggestions |Allows a service to suggest a set of changes in the context of the current activity (e.g. changing the dose of a medication currently being prescribed, for the order-sign activity). If suggestions are present, selectionBehavior MUST also be provided.|
|selectionBehavior |CONDITIONAL |string |Describes the intended selection behavior of the suggestions in the card. Allowed values are: at-most-one, indicating that the user may choose none or at most one of the suggestions; any, indicating that the end user may choose any number of suggestions including none of them and all of them. CDS Clients that do not understand the value MUST treat the card as an error.|
|overrideReasons |OPTIONAL |array of Coding |Override reasons can be selected by the end user when overriding a card without taking the suggested recommendations. The CDS service MAY return a list of override reasons to the CDS client. If override reasons are present, the CDS Service MUST populate a display value for each reason's Coding. The CDS Client SHOULD present these reasons to the clinician when they dismiss a card. A CDS Client MAY augment the override reasons presented to the user with its own reasons.|
|links |OPTIONAL |array of Links |Allows a service to suggest a link to an app that the user might want to run for additional information or to help guide a decision.|

`indicator` above helps make sense of this error message. 
```
DynamicValue expression Info encountered exception: Please use the priority path when setting indicator values when using FHIR R4 or higher for CDS Hooks evaluation
```
So I have to do something with the "Info" expression of the PlanDefinition. This "Info" isn't an `indicator` though 'info' is one of this indicator values. The CQL for info is
```
define "Info":
'info'
```
i.e. it's just the string 'info'. It's not a card indicator. So it looks like I'll have to do my first edit on HIVScreening.cql to do something like:
```
define "Routine":
'routine' 
```
etc also for 
|urgent | asap | stat

Or just change the value in the Plandefinition to text/cql "'routine'"
