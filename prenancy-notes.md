With help from  CHATGPT:

Sample lab urine pregnancy test.
```json
{
  "resourceType": "Observation",
  "id": "example-obs",
  "status": "final",
  "code": {
    "coding": [
      {
        "system": "http://loinc.org",
        "code": "2106-3",
        "display": "Choriogonadotropin (pregnancy test) [Presence] in Urine"
      }
    ]
  },
  "subject": {
    "reference": "Patient/123"
  },
  "effectiveDateTime": "2024-04-20T12:34:56+00:00",
  "valueCodeableConcept": {
    "coding": [
      {
        "system": "http://snomed.info/sct",
        "code": "10828004",
        "display": "Positive"
      }
    ]
  },
  "interpretation": {
    "coding": [
      {
        "system": "http://terminology.hl7.org/CodeSystem/v3-ObservationInterpretation",
        "code": "POS",
        "display": "Positive"
      }
    ]
  }
}
```
In the valueset one should include all three of these LOINCS:
|code|display|
|---|---|
|2106-3|Choriogonadotropin (pregnancy test) [Presence] in Urine|
|2112-1|Choriogonadotropin.beta subunit (pregnancy test) [Presence] in Urine|
|80384-1|Choriogonadotropin (pregnancy test) [Presence] in Urine by Rapid immunoassay|