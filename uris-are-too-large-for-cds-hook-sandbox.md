Valuesets that probably break cds-hooks sandbox. 

"HIV-1 HIV 2 Ab Ag tests Codes"
"Pregnancy Observations Codes"

In the CDS Services description (result of http://localhost:8080/cds-services) the problem areas are:
- item 21 
  Starts with "Condition?patient\u003dPatient/{{context.patientId}}\u0026code\u003dhttp://snomed.info/sct|266130009…”
  Corresponds to valueset-nachc-c1-de2.json
  concept code "Syphilis Codes"

- Item 31  
  - starts with "MedicationStatement?subject\u003dPatient/{{context.patientId}}\u0026code\u003dhttp://hl7.org/fhir/sid/icd-10|F11.10 
  - corresponds to valueset-nachc-f1-de201.json
  - concept code "Injection Drug Use Codes"

Exceeds maximum uri length of jetty server

The two files have ~180 and ~240 element. Do we need that many conditions and meds? 

Next are uris 

|key code|stub|definition|corrected?|
|---|---|---|
|266130003|c1-de1-codes-grouper|"Syphilis Diagnosis Codes Grouper"|true|
|90428001|d1-de1-codes-grouper|"Gonorrhea Diagnosis Codes Grouper"|true|
|10.01|f2-de1132|"Pregnancy Conditions Codes"|true|
|10.01|2.16.840.1.113762.1.4.1235.497|"Pregnancy Conditions Codes"|true|
|9769006|f1-de16|"Injection Drug Use Diagnosis Codes"|false|
