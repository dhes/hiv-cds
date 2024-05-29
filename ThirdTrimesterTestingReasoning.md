Third Trimester Testing Reasoning

CDC preamble: 'A second HIV test during the third trimester is recommended for women who meet one or more of the following criteria: '

| CDC text | Implementation | 
|---|---|
|'Women who receive health care in jurisdictions with elevated incidence of HIV or AIDS among women aged 15--45 years.'|Access [Atlas Plus](https://www.cdc.gov/nchhstp/about/atlasplus.html). Create a list of high-prevalence states in CQL. Apply this list to Patient.address.state.| 
|'Women who receive health care in facilities in which prenatal screening identifies at least one HIV-infected pregnant woman per 1,000 women screened.'|Leave it up to these institutions to create their own policy of testing all women in the second trimester. CDS not required.|
|'Women who are known to be at high risk for acquiring HIV...injection-drug users'|FHIR Observation with code = CodableConcept SNOMED CT 228388006 'Intravenous Drug User (finding)' and value = true|
|'Women who are known to be at high risk for acquiring HIV...sex partners of injection-drug users'|FHIR Observation with code = CodableConcept SNOMED CT 266974005 'Human immunodeficiency virus risk lifestyle (finding)' and value = true|
|'Women who are known to be at high risk for acquiring HIV...women who exchange sex for money or drugs'|FHIR Observation with code = CodableConcept SNOMED CT 159798008 'women who exchange sex for money or drugs (occupation)' and value = true|
|'Women who are known to be at high risk for acquiring HIV...women who are sex partners of HIV-infected persons'|FHIR Observation with code = CodableConcept SNOMED CT 266974005 'Human immunodeficiency virus risk lifestyle (finding)' and value = true|
|'Women who are known to be at high risk for acquiring HIV...women who have had a new sex partner during this pregnancy'|FHIR Observation with code = CodableConcept SNOMED CT 771458000 'New sexual contact (finding)' and value = true|
|'Women who are known to be at high risk for acquiring HIV...women who have had more than one sex partner during this pregnancy'|FHIR Observation with code = CodableConcept SNOMED CT 225516002  'Multiple sexual contacts (finding)' and value = true|
|'Women who have signs or symptoms consistent with acute HIV infection.'|This is routine care. CDS not needed.|

Wherever specific SNOMED CT codes were unavailalbe I chose the catch-all SNOMED CT 228388006 'Human immunodeficiency virus risk lifestyle (finding)'

