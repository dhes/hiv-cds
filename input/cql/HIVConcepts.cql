library HIVConcepts

// Code Systems
codesystem "ICD-10": 'http://hl7.org/fhir/sid/icd-10'
codesystem "SNOMED-CT": 'http://snomed.info/sct'
codesystem "LOINC": 'http://loinc.org'
codesystem "RxNorm": 'http://www.nlm.nih.gov/research/umls/rxnorm'
codesystem "CPT": 'http://www.ama-assn.org/go/cpt'
codesystem "HCPCS": 'https://www.cms.gov/Medicare/Coding/HCPCSReleaseCodeSets'
codesystem "CIEL": 'http://hl7.org/fhir/sid/ciel'
codesystem "ICD-11": 'http://hl7.org/fhir/sid/icd-11'
codesystem "ICHI": 'https://mitel.dimi.uniud.it/ichi/#http://id.who.int/ichi'
codesystem "ICF": 'http://hl7.org/fhir/sid/icf-nl'
codesystem "NDC": 'http://hl7.org/fhir/sid/ndc'
codesystem "NIDA": 'https://cde.drugabuse.gov'
codesystem "Extended Codes CodeSystem": 'http://fhir.org/guides/nachc/hiv-cds/CodeSystem/hiv-custom'
// DH
codesystem "Observation Interpretation": 'http://terminology.hl7.org/CodeSystem/v3-ObservationInterpretation'

// Value Sets
valueset "Encounter Type Codes": 'http://fhir.org/guides/nachc/hiv-cds/ValueSet/nachc-a0-de2'
valueset "Sexual Orientation Codes": 'http://fhir.org/guides/nachc/hiv-cds/ValueSet/nachc-a0-de49'
valueset "Gender Identity Codes": 'http://fhir.org/guides/nachc/hiv-cds/ValueSet/nachc-a0-de56'
valueset "HIV infection as a condition Codes": 'http://fhir.org/guides/nachc/hiv-cds/ValueSet/nachc-a1-de2'
valueset "HIV-1 HIV 2 Ab Ag tests Codes": 'http://fhir.org/guides/nachc/hiv-cds/ValueSet/nachc-a2-de2'
valueset "HIV Viral Load Codes": 'http://fhir.org/guides/nachc/hiv-cds/ValueSet/nachc-a2-de173'
// valueset "HIV Test Codes Grouper": 'http://fhir.org/guides/nachc/hiv-cds/ValueSet/nachc-a2-de1-codes-grouper'
valueset "HIV Test Ordered Codes": 'http://fhir.org/guides/nachc/hiv-cds/ValueSet/nachc-a2-de217'
valueset "Hepatitis C Virus Infection (Disorders) Codes": 'http://fhir.org/guides/nachc/hiv-cds/ValueSet/nachc-b1-de2'
valueset "Chronic Infection of liver due to Hepatitis C virus Codes": 'http://fhir.org/guides/nachc/hiv-cds/ValueSet/nachc-b1-de31'
valueset "HCV Infection (Organism or Substance in Lab Results) Codes": 'http://fhir.org/guides/nachc/hiv-cds/ValueSet/nachc-b1-de33'
valueset "Hepatitis C condition Codes": 'http://fhir.org/guides/nachc/hiv-cds/ValueSet/nachc-b1-de61'
valueset "Hepatitis C Diagnosis Codes Grouper": 'http://fhir.org/guides/nachc/hiv-cds/ValueSet/nachc-b1-de1-codes-grouper'
valueset "Hepatitis C Ag Codes": 'http://fhir.org/guides/nachc/hiv-cds/ValueSet/nachc-b2-de2'
valueset "Hepatitis C nucleic acid Codes": 'http://fhir.org/guides/nachc/hiv-cds/ValueSet/nachc-b2-de5'
valueset "Hepatitis C virus antibody test Codes": 'http://fhir.org/guides/nachc/hiv-cds/ValueSet/nachc-b2-de41'
valueset "Hepatitis C virus nucleic (RNA) test Codes": 'http://fhir.org/guides/nachc/hiv-cds/ValueSet/nachc-b2-de81'
valueset "Hepatitis C Test Codes": 'http://fhir.org/guides/nachc/hiv-cds/ValueSet/nachc-b2-de103'
valueset "Hepatitis C Test Codes Grouper": 'http://fhir.org/guides/nachc/hiv-cds/ValueSet/nachc-b2-de1-codes-grouper'
valueset "Hepatitis C Procedures Codes": 'http://fhir.org/guides/nachc/hiv-cds/ValueSet/nachc-b2-de113'
// valueset "Syphilis Codes": 'http://fhir.org/guides/nachc/hiv-cds/ValueSet/nachc-c1-de2'
valueset "Syphilis (Organism or Substance in Lab Results) Codes": 'http://fhir.org/guides/nachc/hiv-cds/ValueSet/nachc-c1-de185'
valueset "Syphilis condition Codes": 'http://fhir.org/guides/nachc/hiv-cds/ValueSet/nachc-c1-de192'
// valueset "Syphilis Diagnosis Codes Grouper": 'http://fhir.org/guides/nachc/hiv-cds/ValueSet/nachc-c1-de1-codes-grouper'
valueset "Syphilis (Tests for Treponema pallidum Nucleic Acid) Codes": 'http://fhir.org/guides/nachc/hiv-cds/ValueSet/nachc-c2-de2'
valueset "Syphilis (Tests for Treponemal or Non Antibody) Codes": 'http://fhir.org/guides/nachc/hiv-cds/ValueSet/nachc-c2-de8'
valueset "Syphilis Test Codes Grouper": 'http://fhir.org/guides/nachc/hiv-cds/ValueSet/nachc-c2-de1-codes-grouper'
valueset "Gonococcal Infections and Venereal Diseases Codes": 'http://fhir.org/guides/nachc/hiv-cds/ValueSet/nachc-d1-de2'
valueset "Gonorrhea Organism or Substance in Lab Results Codes": 'http://fhir.org/guides/nachc/hiv-cds/ValueSet/nachc-d1-de167'
valueset "Gonorrhea Secondary Sites Codes": 'http://fhir.org/guides/nachc/hiv-cds/ValueSet/nachc-d1-de182'
// valueset "Gonorrhea Diagnosis Codes Grouper": 'http://fhir.org/guides/nachc/hiv-cds/ValueSet/nachc-d1-de1-codes-grouper'
valueset "Gonorrhea Tests for Neisseria gonorrhea by Culture Codes": 'http://fhir.org/guides/nachc/hiv-cds/ValueSet/nachc-d2-de2'
valueset "Gonorrhea Tests for Neisseria Nucleic Acid Codes": 'http://fhir.org/guides/nachc/hiv-cds/ValueSet/nachc-d2-de17'
valueset "Gonorrhea Tests for Neisseria species by Culture Codes": 'http://fhir.org/guides/nachc/hiv-cds/ValueSet/nachc-d2-de60'
valueset "Gonorrhea test Codes": 'http://fhir.org/guides/nachc/hiv-cds/ValueSet/nachc-d2-de67'
valueset "Gonorrhea Tests and Chlamydia/Gonorrhea Combined Tests Codes": 'http://fhir.org/guides/nachc/hiv-cds/ValueSet/nachc-d2-de101'
valueset "Gonorrhea Test Codes Grouper": 'http://fhir.org/guides/nachc/hiv-cds/ValueSet/nachc-d2-de1-codes-grouper'
valueset "Chlamydia Codes": 'http://fhir.org/guides/nachc/hiv-cds/ValueSet/nachc-e1-de2'
valueset "Chlamydia Infections and Venereal Diseases Codes": 'http://fhir.org/guides/nachc/hiv-cds/ValueSet/nachc-e1-de27'
valueset "Chlamydia trachomatis Infection Codes": 'http://fhir.org/guides/nachc/hiv-cds/ValueSet/nachc-e1-de32'
valueset "Chlamydia trachomatis organism Codes": 'http://fhir.org/guides/nachc/hiv-cds/ValueSet/nachc-e1-de63'
valueset "Chlamydia Diagnosis Codes Grouper": 'http://fhir.org/guides/nachc/hiv-cds/ValueSet/nachc-e1-de1-codes-grouper'
valueset "Chlamydia Screening Codes": 'http://fhir.org/guides/nachc/hiv-cds/ValueSet/nachc-e2-de2'
valueset "Chlamydia test Codes": 'http://fhir.org/guides/nachc/hiv-cds/ValueSet/nachc-e2-de49'
valueset "Chlamydia Trachomatis Tests, FPAR Codes": 'http://fhir.org/guides/nachc/hiv-cds/ValueSet/nachc-e2-de123'
valueset "Tests for Chlamydia trachomatis Antigen Codes": 'http://fhir.org/guides/nachc/hiv-cds/ValueSet/nachc-e2-de125'
valueset "Tests for Chlamydia trachomatis by Culture Codes": 'http://fhir.org/guides/nachc/hiv-cds/ValueSet/nachc-e2-de154'
valueset "Tests for Chlamydia trachomatis Nucleic Acid Codes": 'http://fhir.org/guides/nachc/hiv-cds/ValueSet/nachc-e2-de164'
valueset "Chlamydia Test Codes Grouper": 'http://fhir.org/guides/nachc/hiv-cds/ValueSet/nachc-e2-de1-codes-grouper'
valueset "Drug Rehabilitation Codes": 'http://fhir.org/guides/nachc/hiv-cds/ValueSet/nachc-f1-de2'
valueset "Injection Findings Codes": 'http://fhir.org/guides/nachc/hiv-cds/ValueSet/nachc-f1-de13'
// valueset "Injection Drug Use Diagnosis Codes": 'http://fhir.org/guides/nachc/hiv-cds/ValueSet/nachc-f1-de16'
// valueset "Injection Drug Use Codes": 'http://fhir.org/guides/nachc/hiv-cds/ValueSet/nachc-f1-de201'
valueset "Pregnancy Encounters Codes": 'http://fhir.org/guides/nachc/hiv-cds/ValueSet/nachc-f2-de2'
valueset "Third Trimester Encounters Codes": 'http://fhir.org/guides/nachc/hiv-cds/ValueSet/nachc-f2-de39'
valueset "Pregnancy Supervision Codes": 'http://fhir.org/guides/nachc/hiv-cds/ValueSet/nachc-f2-de43'
valueset "Maternal Care Codes": 'http://fhir.org/guides/nachc/hiv-cds/ValueSet/nachc-f2-de109'
valueset "Pregnancy Procedures Codes": 'http://fhir.org/guides/nachc/hiv-cds/ValueSet/nachc-f2-de673'
valueset "Pregnancy Observations Codes": 'http://fhir.org/guides/hopena/hiv-cds/ValueSet/pregnancy-observation-codes'
// valueset "Pregnancy Observations Codes": 'http://fhir.org/guides/nachc/hiv-cds/ValueSet/nachc-f2-de905'
// valueset "Pregnancy Conditions Codes": 'http://fhir.org/guides/nachc/hiv-cds/ValueSet/nachc-f2-de1132'
// valueset "Pregnancy Conditions Codes": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113762.1.4.1235.497'
valueset "Post Exposure Prophylaxis Codes": 'http://fhir.org/guides/nachc/hiv-cds/ValueSet/nachc-g1-de2'
valueset "Preferred nPEP Order Codes": 'http://fhir.org/guides/nachc/hiv-cds/ValueSet/nachc-g1-de6'
valueset "Alternative nPEP Order Codes": 'http://fhir.org/guides/nachc/hiv-cds/ValueSet/nachc-g1-de100'
valueset "PEP Medication Prescriptions Codes Grouper": 'http://fhir.org/guides/nachc/hiv-cds/ValueSet/nachc-g1-de5-codes-grouper'
valueset "Preferred nPEP Supplied Codes": 'http://fhir.org/guides/nachc/hiv-cds/ValueSet/nachc-g1-de144'
valueset "Alternative nPEP Supplied Codes": 'http://fhir.org/guides/nachc/hiv-cds/ValueSet/nachc-g1-de299'
valueset "PEP Dispensed Medications Codes Grouper": 'http://fhir.org/guides/nachc/hiv-cds/ValueSet/nachc-g1-de143-codes-grouper'
valueset "Emtricitabine (FTC) 200mg Order Codes": 'http://fhir.org/guides/nachc/hiv-cds/ValueSet/nachc-g2-de2'
valueset "TAF 25mg / FTC 200mg Order Codes": 'http://fhir.org/guides/nachc/hiv-cds/ValueSet/nachc-g2-de7'
valueset "TDF 300mg / FTC 200mg Order Codes": 'http://fhir.org/guides/nachc/hiv-cds/ValueSet/nachc-g2-de15'
valueset "Tenofovir Alafenamide (TAF) 25 mg Order Codes": 'http://fhir.org/guides/nachc/hiv-cds/ValueSet/nachc-g2-de18'
valueset "Tenofovir Disoproxil Fumarate (TDF) 300mg Order Codes": 'http://fhir.org/guides/nachc/hiv-cds/ValueSet/nachc-g2-de22'
valueset "Prep Medication Prescriptions Codes Grouper": 'http://fhir.org/guides/hopena/hiv-cds/ValueSet/preexposure-prophylaxis-meds'
valueset "Emtricitabine (FTC) 200mg Supplied Codes": 'http://fhir.org/guides/nachc/hiv-cds/ValueSet/nachc-g2-de27'
valueset "TAF 25mg / FTC 200mg Supplied Codes": 'http://fhir.org/guides/nachc/hiv-cds/ValueSet/nachc-g2-de35'
valueset "TDF 300mg / FTC 200mg Supplied Codes": 'http://fhir.org/guides/nachc/hiv-cds/ValueSet/nachc-g2-de37'
valueset "Tenofovir Alafenamide (TAF) 25 mg Supplied Codes": 'http://fhir.org/guides/nachc/hiv-cds/ValueSet/nachc-g2-de78'
valueset "Tenofovir Disoproxil Fumarate (TDF) 300mg Supplied Codes": 'http://fhir.org/guides/nachc/hiv-cds/ValueSet/nachc-g2-de79'
// valueset "Prep Dispensed Medications Codes Grouper": 'http://fhir.org/guides/nachc/hiv-cds/ValueSet/nachc-g2-de26-codes-grouper'
// DH
valueset "Tuberculosis (Disorders) (ICD10CM)": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113762.1.4.1146.451'

/* MANUAL VALUESETS -- *DO NOT OVERWRITE* */
valueset "Gay Or Bisexual": 'http://fhir.org/guides/nachc/hiv-cds/ValueSet/GayOrBisexual'
valueset "Transgender": 'http://fhir.org/guides/nachc/hiv-cds/ValueSet/Transgender'
// valueset "TB": 'http://example.org/fhir/ValueSet/tuberculosis-comprehensive-value-set'

// Codes
code "Sexual Orientation": '76690-7' from "LOINC" display 'Sexual orientation'
code "Gender Identity": '76691-5' from "LOINC" display 'Gender identity'
code "HIV Test": 'NACHC.A2.DE1' from "Extended Codes CodeSystem" display 'HIV Test'
code "Hepatitis C Test": 'NACHC.B2.DE1' from "Extended Codes CodeSystem" display 'Hepatitis C Test'
code "Syphilis Test": 'NACHC.C2.DE1' from "Extended Codes CodeSystem" display 'Syphilis Test'
code "Gonorrhea Test": 'NACHC.D2.DE1' from "Extended Codes CodeSystem" display 'Gonorrhea Test'
code "Chlamydia Test": 'NACHC.E2.DE1' from "Extended Codes CodeSystem" display 'Chlamydia Test'
code "Injection Findings": 'NACHC.F1.DE12' from "Extended Codes CodeSystem" display 'Injection Findings'
code "Pregnancy Observations": 'NACHC.F2.DE904' from "Extended Codes CodeSystem" display 'Pregnancy Observations'
code "Previous HIV Screening": 'NACHC.H1.DE1' from "Extended Codes CodeSystem" display 'Previous HIV Screening'
code "Previous HIV Diagnosis": 'NACHC.H1.DE2' from "Extended Codes CodeSystem" display 'Previous HIV Diagnosis'
code "Patient Currently Pregnant": 'NACHC.H1.DE3' from "Extended Codes CodeSystem" display 'Patient Currently Pregnant'
code "Patient Diagnosed with HCV": 'NACHC.H1.DE4' from "Extended Codes CodeSystem" display 'Patient Diagnosed with HCV'
code "Patient Diagnosed with Syphilis": 'NACHC.H1.DE5' from "Extended Codes CodeSystem" display 'Patient Diagnosed with Syphilis'
code "Patient Diagnosed with Gonorrhea": 'NACHC.H1.DE6' from "Extended Codes CodeSystem" display 'Patient Diagnosed with Gonorrhea'
code "Patient Diagnosed with Chlamydia": 'NACHC.H1.DE7' from "Extended Codes CodeSystem" display 'Patient Diagnosed with Chlamydia'
code "Patient has used Injection Drugs": 'NACHC.H1.DE8' from "Extended Codes CodeSystem" display 'Patient has used Injection Drugs'
code "Seeking STD Treatment": 'NACHC.H1.DE9' from "Extended Codes CodeSystem" display 'Seeking STD Treatment'
// code "Previous experience with PREP": 'NACHC.H1.DE10' from "Extended Codes CodeSystem" display 'Previous experience with PREP'
code "Sexual Activity - Past Year": 'NACHC.H1.DE11' from "Extended Codes CodeSystem" display 'Sexual Activity - Past Year'
code "Sexual Activity - History": 'NACHC.H1.DE12' from "Extended Codes CodeSystem" display 'Sexual Activity - History'
// code "Sexual Activity - Men": 'NACHC.H1.DE13' from "Extended Codes CodeSystem" display 'Sexual Activity - Men'
code "Sexual Activity - Women": 'NACHC.H1.DE14' from "Extended Codes CodeSystem" display 'Sexual Activity - Women'
code "Sexual Activity - Number of Partners": 'NACHC.H1.DE15' from "Extended Codes CodeSystem" display 'Sexual Activity - Number of Partners'
code "Sexual Activity - New Partner Past 3 Months": 'NACHC.H1.DE16' from "Extended Codes CodeSystem" display 'Sexual Activity - New Partner Past 3 Months'
code "Sexual Activity - Partners History": 'NACHC.H1.DE17' from "Extended Codes CodeSystem" display 'Sexual Activity - Partners History'
code "Sexual Activity - Partners Number of Partners": 'NACHC.H1.DE18' from "Extended Codes CodeSystem" display 'Sexual Activity - Partners Number of Partners'
code "Sexual Activity - Partners HIV History": 'NACHC.H1.DE19' from "Extended Codes CodeSystem" display 'Sexual Activity - Partners HIV History'
code "Sexual Activity - Drug or Alcohol Use": 'NACHC.H1.DE20' from "Extended Codes CodeSystem" display 'Sexual Activity - Drug or Alcohol Use'
code "Sexual Activity - Exchanged for Sex": 'NACHC.H1.DE21' from "Extended Codes CodeSystem" display 'Sexual Activity - Exchanged for Sex'
code "Sexual Activity - Coercion": 'NACHC.H1.DE22' from "Extended Codes CodeSystem" display 'Sexual Activity - Coercion'
code "Sexual Activity - Kind of Sex - Anal": 'NACHC.H1.DE23' from "Extended Codes CodeSystem" display 'Sexual Activity - Kind of Sex - Anal'
code "Sexual Activity - Male - Kind of Sex - Receptive Anal": 'NACHC.H1.DE24' from "Extended Codes CodeSystem" display 'Sexual Activity - Male - Kind of Sex - Receptive Anal'
code "Sexual Activity - Male - Kind of Sex - Insertive Anal": 'NACHC.H1.DE25' from "Extended Codes CodeSystem" display 'Sexual Activity - Male - Kind of Sex - Insertive Anal'
code "Sexual Activity - Kind of Sex - Vaginal": 'NACHC.H1.DE26' from "Extended Codes CodeSystem" display 'Sexual Activity - Kind of Sex - Vaginal'
code "DAST 10 Question 1": '3254039' from "NIDA" display 'Have you used drugs other than those required for medical reasons'
code "DAST 10 Question 2": '3254057' from "NIDA" display 'Do you use more than one drug at a time'
code "DAST 10 Question 3": '3254058' from "NIDA" display 'Are you always able to stop using drugs when you want to'
code "DAST 10 Question 4": '3254061' from "NIDA" display 'Have you had blackouts or flashbacks as a result of drug use'
code "DAST 10 Question 5": '3254063' from "NIDA" display 'Do you ever feel bad or guilty about your drug use'
code "DAST 10 Question 6": '3254065' from "NIDA" display 'Does your spouse (or parents) ever complain about your involvement with drugs'
code "DAST 10 Question 7": '3254066' from "NIDA" display 'Have you neglected your family because of your use of drugs'
code "DAST 10 Question 8": '3254067' from "NIDA" display 'Have you engaged in illegal activities in order to obtain drugs'
code "DAST 10 Question 9": '3254070' from "NIDA" display 'Have you ever experienced withdrawal symptoms (felt sick) when you stopped taking drugs'
code "DAST 10 Question 10": '3254072' from "NIDA" display 'Have you had medical problems as a result of your drug use (e.g., memory loss, hepatitis, convulsions, bleeding, etc.)'
code "DAST 10 Score": '82667-7' from "LOINC" display 'Total Score [DAST-10]'
// DH follows
code "Positive Test Value": '10828004' from "SNOMED-CT" display 'Positive Test Value'
code "Positive Test Interpretation": 'POS' from "Observation Interpretation" display 'Positive Test Interpretation'
code "Estimated Date of Delivery": '161714006' from "SNOMED-CT" display 'Estimated date of delivery (observable entity)'
code "HIV Risky Lifestyle": '266974005' from "SNOMED-CT" display 'Human immunodeficiency virus risk lifestyle (finding)'
code "Intravenous Drug User": '228388006' from "SNOMED-CT" display 'Intravenous drug user (finding)'
code "Exchanges Sex for Drugs or Money": '159798008' from "SNOMED-CT" display 'Exchanges sex for money or drugs (occupation)'
code "Multiple Sex Partners": '225516002' from "SNOMED-CT" display 'Multiple Sexual Contact (finding)'
code "New Sex Partner": '771458000' from "SNOMED-CT" display 'New sexual contact (finding)'
code "Has sex with men": '472986005' from "SNOMED-CT" display 'Sexually active with men (finding)'
code "Pregnancy Conditions Codes": 'Z33.1' from "ICD-10" display 'Pregnant state, incidental'