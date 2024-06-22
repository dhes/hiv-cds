Valuesets that probably break cds-hooks sandbox. 

"HIV-1 HIV 2 Ab Ag tests Codes"
"Pregnancy Observations Codes"

In the CDS Services description (result of http://localhost:8080/cds-services) the problem areas are:
- item 21 
  Starts with "Condition?patient\u003dPatient/{{context.patientId}}\u0026code\u003dhttp://snomed.info/sct|266130009…”
  Corresponds to valueset-nachc-c1-de2.json

- Item 31  
  - starts with "MedicationStatement?subject\u003dPatient/{{context.patientId}}\u0026code\u003dhttp://hl7.org/fhir/sid/icd-10|F11.10 
  - corresponds to valueset-nachc-f1-de201.json

Exceeds maximum uri length of jetty server

The two files have ~180 and ~240 element. Do we need that many conditions and meds? 