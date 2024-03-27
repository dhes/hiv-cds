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

| Field             | Optionality | Type                 | Description                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
| ----------------- | ----------- | -------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| uuid              | OPTIONAL    | string               | Unique identifier of the card. MAY be used for auditing and logging cards and SHALL be included in any subsequent calls to the CDS service's feedback endpoint.                                                                                                                                                                                                                                                                                                                          |
| summary           | REQUIRED    | string               | One-sentence, <140-character summary message for display to the user inside of this card.                                                                                                                                                                                                                                                                                                                                                                                                |
| detail            | OPTIONAL    | string               | Optional detailed information to display; if provided MUST be represented in (GitHub Flavored) Markdown. (For non-urgent cards, the CDS Client MAY hide these details until the user clicks a link like "view more details...").                                                                                                                                                                                                                                                         |
| indicator         | REQUIRED    | string               | Urgency/importance of what this card conveys. Allowed values, in order of increasing urgency, are: info, warning, critical. The CDS Client MAY use this field to help make UI display decisions such as sort order or coloring.                                                                                                                                                                                                                                                          |
| source            | REQUIRED    | object               | Grouping structure for the Source of the information displayed on this card. The source should be the primary source of guidance for the decision support the card represents.                                                                                                                                                                                                                                                                                                           |
| suggestions       | OPTIONAL    | array of Suggestions | Allows a service to suggest a set of changes in the context of the current activity (e.g. changing the dose of a medication currently being prescribed, for the order-sign activity). If suggestions are present, selectionBehavior MUST also be provided.                                                                                                                                                                                                                               |
| selectionBehavior | CONDITIONAL | string               | Describes the intended selection behavior of the suggestions in the card. Allowed values are: at-most-one, indicating that the user may choose none or at most one of the suggestions; any, indicating that the end user may choose any number of suggestions including none of them and all of them. CDS Clients that do not understand the value MUST treat the card as an error.                                                                                                      |
| overrideReasons   | OPTIONAL    | array of Coding      | Override reasons can be selected by the end user when overriding a card without taking the suggested recommendations. The CDS service MAY return a list of override reasons to the CDS client. If override reasons are present, the CDS Service MUST populate a display value for each reason's Coding. The CDS Client SHOULD present these reasons to the clinician when they dismiss a card. A CDS Client MAY augment the override reasons presented to the user with its own reasons. |
| links             | OPTIONAL    | array of Links       | Allows a service to suggest a link to an app that the user might want to run for additional information or to help guide a decision.                                                                                                                                                                                                                                                                                                                                                     |

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

2024-02-15

Look to this CDS Hooks Service [PlanDefinition](CDS Hooks Service PlanDefinition). it `Defines a PlanDefinition that implements the behavior for a CDS Hooks service`. 

Replacing "Info" as a cql-expression with "'routine'" as a cql removed the OperationOutcome error. 

Execute CQL is not working on HIVScreening. Data path should be `Data path: D:\src\code\cqframework\hiv-cds\input\tests\PlanDefinition\Screening` but is `/Users/danheslinga/hiv-cds/input/tests`

I made a duplicate of `input/tests/PlanDefinition/Screening` to `input/tests/PlanDefinition/HIVScreening` and now execute CQL works better.

Now working with `DrugAbuseQuestionsPatient`. Apparently she had an HIV test two months before her encounter so at the time of the encounter she is not due. I had to make the status of the encounter `finished` to get a sensible result from `Execute CQL`. Maybe if I made the visit date today it would also have worked. Let's try that. Didn't work. So it seems confirmed that all of the encounter statuses have to be changed to finished. Will load her testing bundle with 
```
curl -d "@input/tests/PlanDefinition/HIVScreening/tests-DrugAbuseQuestionsPatient-bundle.json" -H "Content-Type: application/json" -X POST http://localhost:8080/fhir 
```
OK - that's very nice. Running
```
http://localhost:8080/fhir/PlanDefinition/HIVScreening/$apply?subject=Patient/DrugAbuseQuestionsPatient
```
BTW HIVContactDataElements.cql uses `context Encounter`. That'll be new. 

Produces an action element that corresponds with the `Execute CQL` procedure. Here is the RequestGrou.action.action
```
      "action": [ {
        "title": "HIV Screening Not Recommended at this time. It has been 63 days since last HIV Screening.",
        "description": "In low prevalence settings, in which the majority of clients are at minimal risk, targeted HIV testing on the basis of risk screening was considered more feasible for identifying limited numbers of HIV-infected persons. The Task Force concluded that such screening would detect additional patients with HIV, but the overall number would be limited, and the potential benefits did not clearly outweigh the burden on primary care practices or the potential harms of a general HIV screening program.",
        "condition": [ {
          "kind": "applicability",
          "expression": {
            "description": "Determine if Patient is in screening population.",
            "language": "text/cql-identifier",
            "expression": "Risk Level Condition"
          }
        } ]
```
and here is the `Execute CQL` results
```
Risk Level Recommendation=HIV Screening Not Recommended at this time. It has been 63 days since last HIV Screening.
```
Progress. Next steps - fix up
>      "diagnostics": "DynamicValue expression Risk Level Indicator Status encountered >exception: Please use the priority path when setting indicator values when using FHIR >R4 or higher for CDS Hooks evaluation"

Then fix up the rest of the test bundle encounters like done with `DrugAbuseQuestionsPatient` and tive them a run!. You also have to remove all references to Resource PractitionerRole/hiv-practitionerrole-example. 

OK test files are fixed up, let's load up the rest. 
```
curl -d "@input/tests/PlanDefinition/HIVScreening/tests-DrugAbuseScreeningPatient-bundle.json" -H "Content-Type: application/json" -X POST http://localhost:8080/fhir
```
```
curl -d "@input/tests/PlanDefinition/HIVScreening/tests-ExclusionPatient-bundle.json" -H "Content-Type: application/json" -X POST http://localhost:8080/fhir
```
```
curl -d "@input/tests/PlanDefinition/HIVScreening/tests-HighRiskIDUPatient-bundle.json" -H "Content-Type: application/json" -X POST http://localhost:8080/fhir
```
```
curl -d "@input/tests/PlanDefinition/HIVScreening/tests-HighRiskPregnantPatient-bundle.json" -H "Content-Type: application/json" -X POST http://localhost:8080/fhir
```
```
curl -d "@input/tests/PlanDefinition/HIVScreening/tests-HighRiskSTDPatient-bundle.json" -H "Content-Type: application/json" -X POST http://localhost:8080/fhir
```
```
curl -d "@input/tests/PlanDefinition/HIVScreening/tests-InclusionPatient-bundle.json" -H "Content-Type: application/json" -X POST http://localhost:8080/fhir
```
```
curl -d "@input/tests/PlanDefinition/HIVScreening/tests-MSMPatient-bundle.json" -H "Content-Type: application/json" -X POST http://localhost:8080/fhir
```
After removing a couple of dead references, those are in. 

2024-02-16

Today let's try to write a set of Thunderclient test on these newly loaded PlanDefinitions and patients. 

It appears that the value[x] of the HIV test in this project are not actually values but a more detailed description of the test itself. That seems to contradict the description of value[x] in the specs as the 'actual' result. I think a ServiceRequest with `status='completed'` might be more appropriate. The most likely clinical scenario would be an Observation with an actual valueBoolean. Screen if DAST >=6. All patients in this table have an expired DAST test. 


Maybe I should bump up the dates of the visits and the questionnaires. 

Is this an error in coding? 
in HIVScreening.cql
```
define "Patient is Gay or Bisexual":
      HDE."Sexual Orientation" in Cx."Gay Or Bisexual"
```
In HIVDataElements.cql
```
define "Sexual Orientation":
  NC.MostRecent(
    [Observation: Cx."Sexual Orientation"] O
      where O.status in { 'final', 'amended', 'corrected' }
  ).value as FHIR.CodeableConcept
```
So HDE.HDE."Sexual Orientation" requires an Observation of "Gay or Bisexual". All of the examples embed sexual preference into the Patient resource as an extension. `Gay` is a key decision element. Best fix would be to create and Observation for each patient. What would this observation look like?
```
{
	"resourceType": Observation,
	"id": "",
	"status" : "final",
	"subject": {
    "reference" : "",
    "display" : ""},
	"effectiveDateTime" : "2013-04-02T09:30:10+01:00",
  "issued" : "2013-04-03T15:30:10+01:00",
	"code" : {
    "coding" : [{
      "system" : "http://loinc.org",
      "code" : "76691-5",
      "display" : "gender identity"
    }]
  },	"valueCodeableConcept": {
	"coding": [
		{
			"system": "http://fhir.org/guides/nachc/hiv-cds/CodeSystem/hiv-custom",
			"code": "NACHC.A0.DE49",
			"display": "Lesbian, gay or homosexual"
		},
		{
			"system": "http://snomed.info/sct",
			"code": "38628009",
			"display": "Gay"
		},
	]
}
```

2024-02-17

Or you could start from the [US Core](https://build.fhir.org/ig/HL7/US-Core/StructureDefinition-us-core-observation-sexual-orientation.html) example.
```
{
  "resourceType" : "Observation",
  "id" : "sexual-orientation-example",
  "meta" : {
    "profile" : ["http://hl7.org/fhir/us/core/StructureDefinition/us-core-observation-sexual-orientation|7.0.0-ballot"]
  },
  "text" : {
    "status" : "generated",
    "div" : "<div xmlns=\"http://www.w3.org/1999/xhtml\"><p><b>Generated Narrative: Observation</b><a name=\"sexual-orientation-example\"> </a></p><div style=\"display: inline-block; background-color: #d9e0e7; padding: 6px; margin: 4px; border: 1px solid #8da1b4; border-radius: 5px; line-height: 60%\"><p style=\"margin-bottom: 0px\">Resource Observation &quot;sexual-orientation-example&quot; </p><p style=\"margin-bottom: 0px\">Profile: <a href=\"StructureDefinition-us-core-observation-sexual-orientation.html\">US Core Observation Sexual Orientation Profile (version 7.0.0-ballot)</a></p></div><p><b>status</b>: final</p><p><b>category</b>: Social History <span style=\"background: LightGoldenRodYellow; margin: 4px; border: 1px solid khaki\"> (<a href=\"http://terminology.hl7.org/5.3.0/CodeSystem-observation-category.html\">Observation Category Codes</a>#social-history)</span></p><p><b>code</b>: Sexual orientation <span style=\"background: LightGoldenRodYellow; margin: 4px; border: 1px solid khaki\"> (<a href=\"https://loinc.org/\">LOINC</a>#76690-7)</span></p><p><b>subject</b>: <a href=\"Patient-example.html\">Patient/example</a> &quot; SHAW&quot;</p><p><b>effective</b>: 2020-01-11</p><p><b>value</b>: Asked But Declined <span style=\"background: LightGoldenRodYellow; margin: 4px; border: 1px solid khaki\"> (<a href=\"http://terminology.hl7.org/5.3.0/CodeSystem-data-absent-reason.html\">DataAbsentReason</a>#asked-declined)</span></p></div>"
  },
  "status" : "final",
  "category" : [{
    "coding" : [{
      "system" : "http://terminology.hl7.org/CodeSystem/observation-category",
      "code" : "social-history",
      "display" : "Social History"
    }]
  }],
  "code" : {
    "coding" : [{
      "system" : "http://loinc.org",
      "code" : "76690-7",
      "display" : "Sexual orientation"
    }],
    "text" : "Sexual orientation"
  },
  "subject" : {
    "reference" : "Patient/example"
  },
  "effectiveDateTime" : "2020-01-11",
  "valueCodeableConcept" : {
    "coding" : [{
      "system" : "http://terminology.hl7.org/CodeSystem/data-absent-reason",
      "code" : "asked-declined",
      "display" : "Asked But Declined"
    }],
    "text" : "Asked But Declined"
  }
}
```
See `sexual-orientation-observation` for my simplifying edit. The possible codes are in the [valueset](https://vsac.nlm.nih.gov/valueset/2.16.840.1.113762.1.4.1240.11/expansion). 

Here are possible valueCodeableConcepts. 
```
20430005	Heterosexual (finding)	SNOMEDCT	2023-09	2.16.840.1.113883.6.96
38628009	Homosexual (finding)	SNOMEDCT	2023-09	2.16.840.1.113883.6.96
42035005	Bisexual (finding)	SNOMEDCT	2023-09	2.16.840.1.113883.6.96
765288000	Sexually attracted to neither male nor female sex (finding)	SNOMEDCT	2023-09	2.16.840.1.113883.6.96
OTH	other	NullFlavor	2023-02	2.16.840.1.113883.5.1008
UNK	unknown	NullFlavor	2023-02	2.16.840.1.113883.5.1008
asked-declined	Asked But Declined	DataAbsentReason	0.1.0	2.16.840.1.113883.4.642.4.1
```
You'll have to add codesystems.
```
"http://terminology.hl7.org/CodeSystem/v3-NullFlavor"
"http://terminology.hl7.org/CodeSystem/data-absent-reason"
```

I've added those to HIVConcepts.cql as well as:
```
valueset "Sexual Orientations": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113762.1.4.1240.11'
```

Here are the possible values in yaml
```
valueCodeableConcept: SNOMED-CT# 20430005 Heterosexual (finding)
valueCodeableConcept: SNOMED-CT# 38628009 Homosexual (finding)
valueCodeableConcept: SNOMED-CT#42035005 Bisexual (finding)
valueCodeableConcept: SNOMED-CT#765288000 Sexually attracted to neither male nor female sex (finding)
valueCodeableConcept: NullFlavor#OTH other
valueCodeableConcept: NullFlavor#UNK unknown
valueCodeableConcept: DataAbsentReason#asked-declined Asked But Declined
```
and json. 
```
  "valueCodeableConcept" : {
    "coding" : [{
      "system" : "SNOMED-CT",
      "code" : "20430005",
      "display" : "Heterosexual (finding)"
    }],
    "text" : "Heterosexual (finding)"
  }
  "valueCodeableConcept" : {
    "coding" : [{
      "system" : "SNOMED-CT",
      "code" : "38628009",
      "display" : "Homosexual (finding)"
    }],
    "text" : "Homosexual (finding)"
  }
  "valueCodeableConcept" : {
    "coding" : [{
      "system" : "SNOMED-CT",
      "code" : "42035005",
      "display" : "Bisexual (finding)"
    }],
    "text" : "Bisexual (finding)"
  }
  "valueCodeableConcept" : {
    "coding" : [{
      "system" : "SNOMED-CT",
      "code" : "765288000",
      "display" : "Sexually attracted to neither male nor female sex (finding)"
    }],
    "text" : "Sexually attracted to neither male nor female sex (finding)"
  }
  "valueCodeableConcept" : {
    "coding" : [{
      "system" : "NullFlavor",
      "code" : "OTH",
      "display" : "other"
    }],
    "text" : "other"
  }
  "valueCodeableConcept" : {
    "coding" : [{
      "system" : "NullFlavor",
      "code" : "UNK",
      "display" : "unknown"
    }],
    "text" : "unknown"
  }
  "valueCodeableConcept" : {
    "coding" : [{
      "system" : "DataAbsentReason",
      "code" : "asked-declined",
      "display" : "Asked But Declined"
    }],
    "text" : "Asked But Declined"
  }

```
OK, I've written up the new resource and created and update bundle. We'll try to upload it. 
```
curl -d "@bundles/plandefinition/UpdateBundles/sexual-orientation-test-observations.json" -H "Content-Type: application/json" -X POST http://localhost:8080/fhir
```

I think I can get away for now without the two new codesets and one new valueset because we're not using those codes in the current logic. I'm going to revert HIVConcepts.cql to its original. You just can't access `Sexually attracted to neither male nor female sex (finding)`,`other`, `unknown` or `Asked But Declined` as codeAbleConcepts. On my first try the Execute CQL is not identifying homosexual/bisexual persons. Maybe it's because the observation date is after the encounter date. Move the Observation date back and reload and retest. 

2024-02-20

Now I have cql logic and test patients that produce the correct response to "Patient is Gay or Bisexual" when Execute CQL is triggered on HIVScreening.cql. I've wiped the HAPI server at `hapi-fhir-jpaserver-starter-fresh` and will now load the bundle from this project to the server as follows. 
```
curl -d "@bundles/plandefinition/HIVScreening/HIVScreening-bundle.json" -H "Content-Type: application/json" -X POST http://localhost:8080/fhir
```

I had to delete a few dead references from the bundle but after that it loaded without errors. Now the first run of 
```
http://localhost:8080/fhir/PlanDefinition/HIVScreening/$apply?subject=Patient/DrugAbuseScreeningPatient
```
produces three OperationOutcome errors.
```
ActivityDefinition http://fhir.org/guides/nachc/hiv-cds/ActivityDefinition/activitydefinition-hiv-screening-request could not be applied and threw exception org.hl7.fhir.exceptions.FHIRException: No resource of type ActivityDefinition found for url: http://fhir.org/guides/nachc/hiv-cds/ActivityDefinition/activitydefinition-hiv-screening-request|null
    
DynamicValue expression Risk Level Indicator Status encountered exception: Please use the priority path when setting indicator values when using FHIR R4 or higher for CDS Hooks evaluation
    
DynamicValue expression Risk Level Condition encountered exception: Unable to resolve path asNeededBoolean.
 
```
Set that aside for now. Is the logic correct? For `DrugAbuseScreeningPatient` it responds. 

>"title": "HIV Screening Not Recommended at this time. It has been 122 days since last HIV Screening.",
>"description": "In low prevalence settings, in which the majority of clients are at minimal risk, targeted HIV testing on the basis of risk screening was considered more feasible for identifying limited numbers of HIV-infected persons. The Task Force concluded that such screening would detect additional patients with HIV, but the overall number would be limited, and the potential benefits did not clearly outweigh the burden on primary care practices or the potential harms of a general HIV screening program."

Looking through the CDC guidelines there is mention of DAST=10 indicating high risk. This cql logic however does contain such a rule:
```
//High Risk -- Drug Abuse
define "Patient is at High Risk Due to Drug Abuse":
  "Patient Has High Degree Of Problems Related To Drug Abuse"
```
So let that be known. 

The DAST total score is not registering in the Execute CQL process on `DrugAbuseScreeningPatient`. It is because the DAST total score observation uses the NACHC score but the HIVConcepts assigns it a LOINC code. 
```
code "DAST 10 Score": '82667-7' from "LOINC" display 'Total Score [DAST-10]'
```

Oh boy, the status of `DrugAbuseScreeningPatient` DAST score observation was `preliminary`. I add a second score that is within one year, `final` and properly coded. Go through all the Observations under input/tests/HIVScreening and correct DAST scores. I think `DrugAbuseScreeningPatient` is the only one with a DAST score =10. There are others that work through specific questions that I'll deal with later. 

2024-02-21

OK I've cleaned up the test files so that the bundles load without errors. 

Here's a starting point for a HIV test result observation. Those present in this repository are not representative of the real world. 
```
{
  "resourceType": "Observation",
  "status": "final",
  "code": {
    "coding": [
      {
        "system": "http://loinc.org",
        "code": "56888-1",
        "display": "HIV 1+2 Ab+HIV1 p24 Ag [Presence] in Serum or Plasma by Immunoassay"
      }
    ],
  "subject": {
    "reference": "Patient/DrugAbuseScreeningPatient"
  },
    "text": "HIV 1+2 Ab+HIV1 p24 Ag [Presence] in Serum or Plasma by Immunoassay"
  },
  "effectiveDateTime": "2021-01-08T10:00:00-07:00",
  "valueCodeableConcept": {
    "coding": [
      {
        "system": "http://snomed.info/sct",
        "code": " 260385009",
        "display": "Negative (qualifier value)"
      }
    ],
    "text": "Negative (qualifier value)"
  }
}

```
In our application we need to use a valueset for Observation.code.coding anyway. I plan to use valueset-nachc-a2-de2. With that in place and one patient (DrugAbuseScreeningPatient) is working properly with `Execute CQL`. Now to create a proper HIV test observation for the other patients that have HIV tests. I've updated individual questions 1-3 in two patients. Time to update the patient summary table. 

### Summary of Test Patients

| Patient ID                       | Summary                                                                                     |Test?|
| -------------------------------- | ------------------------------------------------------------------------------------------- |---|
| DrugAbuseQuestionsPatientBothCodesystems | 22 y.o. gay female with a DAST score of 3 last tested 2021                                          |false|
| DrugAbuseQuestionsPatientNACHCCodeOnly | 22 y.o. gay female with a DAST score of 3 last tested 2021                                             |false|
| DrugAbuseScreeningPatient        | 22 y.o. gay female with a DAST score of 10 laste tested 2021                                                  |true|
| ExclusionPatient                 | 29 y.o. gay female with HIV                                                                 |false|
| HighRiskIDUPatient               | 22 y.o. gay female with strep sepsis last tested 2021 |true|
| HighRiskPregnantPatient          | 45 y.o. straight pregnant patient with Obstetrical tetanus and multiple partners last tested in 2021|true|
| HighRiskSTDPatient               | 40 y.o. straight male with Chronic lymphocytic cholangitis secondary to Hep C seeking STD treatment            |true|
| InclusionPatient                 | 49 y.o. straight male never tested                                                                       |true|
| MSMPatient                       | 49 y.o. male-to-female bisexual transgender with 'number of partners'=true                  |true|

DrugAbuseQuestionsPatientBothCodesystems and DrugAbuseQuestionsPatientNACHCCodeOnly are the same except in their method of coding sexual orientation. 

Comment on HighRiskIDUPatient. This one is not so straightforward. The trigger is the diagnosis NACHC.F1.DE16 ICD10#A40 "streptococcal sepsis". The pathway is as follows. Running Executes CQL you get 
```
Patient is at High Risk Due to Injection Drug Use=true
```
for this patient. In HIVScreening.cql there is 
```
define "Patient is at High Risk Due to Injection Drug Use":
...
        union HC.QualifiedConditions(HDE."Injection Drug Use Diagnosis")
```
which in HIVDataElements.cql links to
```
define "Injection Drug Use Diagnosis":
  [Condition: Cx."Injection Drug Use Diagnosis Codes"] C
    where C.clinicalStatus in FC."Active Condition"
      and C.verificationStatus ~ FC."confirmed"
```
which in turn in HIVConcept.cql links to 
```
valueset "Injection Drug Use Diagnosis Codes": 'http://fhir.org/guides/nachc/hiv-cds/ValueSet/nachc-f1-de16'

```
In input/vocabulary/valuset/generate there is valueset-nachc-f1-de16.json which contains the ICD10 diagnosis of A40 "Streptococcal Sepsis". *Presumtion* of IDU makes this patient 'high risk' and according to CDC guideines the patient should be tested annually. 

2024-02-23

Now this observation which was so long to reveal itseld: The HIVScreening Plan Definition collects six triggers. All but one end with the word Condition. The remainer ends with Criteria. So they are faily easy to sort through in an `Execute CQL` result. 

>Never Tested Condition
>MSM Condition
>Pregnant Condition
>Seeking STD Treatment Condition
>Risk Level Condition
>Meets Exclusion Criteria

You might imagine these being grouped in some way. `Meets Exclusion Criteria` is in a group of its own, as is `Never Tested Condition`. `MSM Condition`and `Seeking STD Treatment Condition` are be special cases of `Risk Level Condition`. `Pregnant Condition` is a class by itself because we screen pregnant womon expecting a lower yield because the consequences of HIV in pregnancy are so great. Whenever the word 'Condition' appears in a CQL definition, it appears as a `condition` in the PlanDefinition. 'Criteria' appear in CQL twice, but only once in PlanDefinition `condition`s. 

So in ExclusionPatient how does Never Had HIV Test get to be false? It's because Inclusion means a certain age and NOT excluded i.e. does not have HIV. The unspoken rule is 'If you have been diagnosed with HIV you have had an HIV test'. 

Here's another question the fixes an existing code breaking problem: because CQL returns null if any element of a collection is null, if you only give a value it the first three questions of the dast and then ask for the latest date in the collection, it will return null. The fix is to add the last 7 questions (ugh, tedious). 

New fundamental correction. The variable "Patient is not Sexually Active" which is based on the data elements
"Sexual Activity - Past Year", "Sexual Activity - History", "Sexual Activity - Men", "Sexual Activity - Women". The current logic tests for the presence of the observation i.e. if the observation is exists the patient is sexually active; if the collection is empty the patient is not documented to be sexually active. An empty set can't possibly infer that the patient is sexually active. As is stands the logic is: 
```
define "Patient is not Sexually Active":
  ( <collection of sexual history observations> ) is not null

```
If it is NOT null then there is an observation which means the patient is sexually active. I think it should read:
```
define "Patient is not documented as Sexually Active":
  ( <collection of sexual history observations> ) **is** null
```
i.e. without the **not**. That removes the negation error and makes the language clearer. This corrects the defintion of "Patient is a No Risk for HIV", but that definition has its own problems (see code comments). That orphans "Male and (Gay or Bisexual) Patient Not Documented Sexually Inactive" because it would document the reverse; and "Patient is at Moderate Risk for HIV" with depends on "Male and (Gay or Bisexual) Patient Not Documented Sexually Inactive" and all of the Risk Level recommendations. 

2024-02-24

Looking again at the definition of "Patient is not Sexually Active":
```
...
where Coalesce(Lower(SexualHistory.value as string) in { 'no' }, SexualHistory.value as boolean = false)
...
```
This condition statement requires that the vales is a string 'no' or a boolean 'false' to be present in the collection. So there are two ways the collection can be empty. One is the case where there are Observations present for the patient that fall in one of the four categories of "Sexual Activity -.." where the value is 'no' or `false`. The other possibility is that there is no Sexual Activity history. In fact none of the patients in the test set have a Sexual Activity history. It would not be surprising if a sexual history were not recorded in a patient's chart. In short an empty collection has no particular meaning but a non-empty collection means that the patient is documented as not sexually active (in one of four ways, which still carries ambiguity). "Sexual Activity" ~ 'false' probably means the patient is not sexually active. What does "Sexual Activity -- Men" ~ 'false' mean. For our purposes I will assume that 'is not null' means this patient is `Documented Not Sexually Active`. But I an going to change the definition from "Patient is not Sexually Active" to "Patient is Documented not Sexually Active".That fits well with its primary use. 

2024-02-25

Now load up the new bundle and run some $apply operations. 

2024-02-27

It seems that ActivityDefinition is not part of the bundling process. I created a bundle at bundles/UpdateBundles/activity-definition.json to address this. It resolved two operationoutcome errors. Now I see the Recommendation and a ServiceRequest in the response. Still seeing the 'Please use the priority path' error. Does it matter? 

So the logic for DrugAbuseQuestionsPatientBothCodesystems goes like this. She doesn't fit the four basic risk categories, which places her in `Risk LevelnCondition`. She actually does not fit High, Moderate, Low or None so falls into the `else` default of `Risk Level Recommendation` because of this: For this patient DrugAbuseQuestionsPatientBothCodesystems, here are the varriable that feed into the Risk Level Recommencation.
```
Patient is at High Risk for HIV=null
Patient is at Moderate Risk for HIV=false
Patient is at No Risk for HIV=false
Patient is at Low Risk for HIV=null
```
feeds into 
```
define "Risk Level Recommendation":
  if "Patient is at High Risk for HIV" and "Over 3 Months has Passed Since Previous HIV Screening" then ...[test q3mo]
  else if "Patient is at Moderate Risk for HIV" and "Over a Year has Passed Since Previous HIV Screening" then ...[test q12mo]
  else if "Patient is at No Risk for HIV" then ...[no test]
  else if "Patient is at Low Risk for HIV" then ...[no test]
  else 'HIV Screening Not Recommended at this time. It has been ' + ToString("Amount of Days Since Previous HIV Screening") + ' days since last HIV Screening.'

```
While it is true that according to protocol she does not require repeat HIV testing. Null is the same as false in CQL conditionals so I guess it doesn't matter. 

2024-02-29

I'm getting a similar error for these PlanDefinition Elements. The common theme is `Expected a list with at most one element, but found a list with multiple elements`.
```
PlanDefinitionProcessor [PlanDefinitionProcessor.java:825] Condition expression *Never Tested Condition* encountered exception: Expected a list with at most one element, but found a list with multiple elements.

PlanDefinitionProcessor [PlanDefinitionProcessor.java:825] Condition expression *MSM Condition* encountered exception: Expected a list with at most one element, but found a list with multiple elements.

PlanDefinitionProcessor [PlanDefinitionProcessor.java:825] Condition expression *Pregnant Condition* encountered exception: Expected a list with at most one element, but found a list with multiple elements.

PlanDefinitionProcessor [PlanDefinitionProcessor.java:825] Condition expression *Seeking STD Treatment* Condition encountered exception: Expected a list with at most one element, but found a list with multiple elements.

PlanDefinitionProcessor [PlanDefinitionProcessor.java:825] Condition expression *Risk Level Condition* encountered exception: Expected a list with at most one element, but found a list with multiple elements.

PlanDefinitionProcessor [PlanDefinitionProcessor.java:796] DynamicValue expression *Patient Name* encountered exception: Expected a list with at most one element, but found a list with multiple elements.
```

2024-03-06

As it stands now, here is what you do to install these CDS tools on the HAPI FHIR JPA server. 

First, on the server's `application.yaml file` enable clinical reasoning and cds hooks.  
```yaml
hapi:
  fhir:
    ### This flag when enabled to true, will avail evaluate measure operations from CR Module.
    ### Flag is false by default, can be passed as command line argument to override.
    cr:
      enabled: true

    cdshooks:
      enabled: true
      clientIdHeaderName: client_id

```
Next from this repository post the `hiv-cds` bundle and `activity-definition.json`.
```
curl -d "@bundles/plandefinition/HIVScreening/HIVScreening-bundle.json" -H "Content-Type: application/json" -X POST http://localhost:8080/fhir

curl -d "@bundles/UpdateBundles/activity-definition.json" -H "Content-Type: application/json" -X POST http://localhost:8080/fhir
```
You can test your implementation by entering this url in a browser. 
```
http://localhost:8080/fhir/PlanDefinition/HIVScreening/$apply?subject=Patient/DrugAbuseScreeningPatient
```

With luck you will get a CarePlan. 

2024-03-28

Note that having an STD (a condition) makes you high ris HIV but Seeking Treatment for STD is a separate entry pathway to getting tested because it puts you in population regardless of age. 