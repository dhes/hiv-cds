library HIVScreening

using FHIR version '4.0.1'

include FHIRHelpers version '4.0.1'
include FHIRCommon called FC
include NACHCCommon called NC
include HIVCommon called HC
include HIVConcepts called Cx
include HIVDataElements called HDE

parameter "Reference Date" DateTime  // can use values such as Now() or a date like @2024-01-01T00:00:00-10:00
  // default @2024-01-01T00:00:00-10:00 // for testing within ExecuteCQL
  default Now() 


// parameter "True" default true
// parameter "Routine" default 'routine'

// parameter "Asap" default 'asap'
// parameter "Urgent" default 'urgent'
// parameter "Stat" default 'stat'
// parameter "Errors" default null
parameter "HIV Higher Prevalence States and Territories" default { 'VI', 'MS', 'NV', 'TX', 'FL', 'LA', 'GA', 'DC' }

// parameter "Routine" default 'routine'
// parameter "Never tested" default false
// parameter "Pregnant" default false
// parameter "Has STD" default false
// parameter "MSM" default false
// parameter "At risk" default false

context Patient

// DH - an organizing principle -- which seems to not be usefule ;()
// define "Condition Organizer":
//   if "Never Tested Condition" then 'Never tested'
//   else if "Pregnant Condition" then 'Pregnant'
//   else if "Seeking STD Treatment Condition" then 'Has STD'
//   else if "MSM Condition" then 'MSM'
//   else if "Risk Level Condition" then 'At risk'
//   else 'HIV screening test not needed.'

define "There is an HIV test after the most recent positive pregnancy test":
  exists ( HDE."HIV Tests" )
    and Last(HDE."HIV Tests").effective > Last(HDE."Positive Pregnancy Observations").effective

// define "There is an HIV test performed after the diagnosis of tuberculosis":
//   exists(HDE."HIV Tests") and
//   Last(HDE."HIV Tests").effective > First(HDE."Tuberculosis diagnosis").onset // Even if there is only one "Tuberculosis diagnosis" you still need a First or Last before it

define "Alive":
  case 
    // when Patient.deceased = true then false //redundant
    
    when Patient.deceased = false then true
    // when "Null Patient.deceased assumed to mean alive" = true and Patient.deceased is null then true // default is false. You're dead unless you're expressly not. 
  
    else false end

define Active:
  if Patient.active = true then true 
    else false

// //for troubleshooging
// define "HDEDAST10Score":
//   HDE."DAST 10 Score"

// define "HDESexual Orientation code":
//   HDE."Sexual Orientation".coding.code.value

// define "HDESexual Orientation code single":
//   singleton from (HDE."Sexual Orientation".coding.code.value)

// define "HDESexual Orientation system":
//   HDE."Sexual Orientation".coding.system.value

// define "CxGay Or Bisexual":
//   Cx."Gay Or Bisexual"

// define "Patient is Gay or Bisexual":
  // singleton from (HDE."Sexual Orientation".coding) in Cx."Gay Or Bisexual"

define "Patient is Gay or Bisexual":
  exists ( HDE."Sexual Orientation".coding ) O
    where ( O in Cx."Gay Or Bisexual" )

// define "Info":
//   'info'

// define "Warning":
//   'warning'

// define "Critical":
//   'critical'

// define "True":
//   true

// define "Routine":
//   'routine'

// define "Asap":
//   'asap'

// define "Urgent":
//   'urgent'

// define "Stat":
//   'stat'

// define "Errors":
//   null

// define "PatientNameGiven":
// Patient.name.given

// define "PatientNameFamily":
// Patient.name.family

// define "Patient Name":
//   First(Patient.name.given.value)
//    + ' ' +
//   First(Patient.name.family.value)

define "Patient Name":
  First(First(Patient.name).given.value) + ' ' + First(Patient.name).family.value

// define "Patient Name Is String":
//   "Patient Name" is String

/* Recommendation Criteria - HIV Screening  */

define "Meets Inclusion Criteria":
  "Patient is between 13 and 64 years old"
    or "Patient is Seeking Treatment for an STD"

// define "Meets Exclusion Criteria":
//   "Active diagnosis of HIV"

// define "In Population":
//   "Meets Inclusion Criteria"
//     and not "Active diagnosis of HIV"

/* OPTIONS:

    1. Recommend Screening 3 months (High Risk - CDC Risk Factors)
    2. Recommend Screening Annually (Moderate Risk - SOGI Risk Factors)
    3. No Recommendation Screening (No Risk) / Low Risk
    4. Recommend Screening Custom Periods (3 months based on specific risk factor -- sexually active MSM w/ prep, etc)
      // MSM / Pregnancy / CDC Recommendation

  // - High Risk
    // CDC RISK FACTORS
    // Drug Abuse (DAST-10)

  // - Medium Risk
    // SOGI ELEMENTS

  // - No Risk
    // Documented not Sexually Active (Risk Factors Questionnaire DE 13 / 14)

  // - Low Risk
    // DEFAULT

  // TEST ORDER:
    Needs ActivityDefinition in the PlanDefinition.
    Need to be able to specify what they are ordering in the configuration.
    ServiceRequest using Data Element Ordered Codes


  // TODO:
  Snooze Options / Override:
    Accept - Place order
    Document Test - ACTION: Questionnaire to support documenting test
    Snooze - 1 month
    Snooze - 12 months
    Patient Declined - ACTION: Document patient preference

*/

/*

ORDER:
  1. Never TESTED
  2. CDC Edge Cases (MSM & Pregnancy)
  3.Risk Scoring
    a. High Risk
    b. Moderate Risk
    c. Low Risk / No Risk

*/

// NEVER TESTED




define "Never Tested Condition":
  if ( 
      "Patient is between 13 and 64 years old"
      and not "Patient has had an HIV Test"
      and not "Active diagnosis of HIV"
     ) 
  then true 
  else false

define "Never Tested Recommendation": // i.e. recommended because...
  if "Never Tested Condition" then 
  '\r\n - This patient has never been tested for HIV.' 
    else ''

define "Never Tested Rationale":
  if "Never Tested Condition" then 
    // '\r\n - CDC recommends that diagnostic HIV testing and opt-out HIV screening be a part of routine clinical care in all health-care settings while also preserving the patients option to decline HIV testing and ensuring a provider-patient relationship conducive to optimal clinical and preventive care.'
  '\r\n - All patients age 13 to 64 years (inclusive) should be tested for HIV at least once.' 
    else ''

define "Never Tested Indicator":
  if "Never Tested Condition" then 'routine' 
    else ''

/* CDC EDGE CASES */
// MSM

define "No HIV Test in the last year":
  exists ( HDE."HIV Tests" )
  and date from Last(HDE."HIV Tests").effective on or before ("Reference Date" - 1 year)

define "No HIV Test in the last three months":
  exists ( HDE."HIV Tests" )
  and date from Last(HDE."HIV Tests").effective on or before ("Reference Date" - 3 months)

define "MSM Condition":
  if (
      not "Active diagnosis of HIV"
      and "Patient is Male" and "Has sex with men"
      and (
           "No HIV Test in the last year"
           or "On pre-exposure prophylaxis" and "No HIV Test in the last three months"
          )
     )
   then true 
   else false

define "MSM Recommendation":
  if "MSM Condition" and "No HIV Test in the last year"
    then '\r\n - This man has sex men and has not had an HIV test for one year.'
  else if "MSM Condition" and "On pre-exposure prophylaxis" and "No HIV Test in the last three months"
    then '\r\n - This man has sex men and is on pre-exposure prophylaxis, and has not had an HIV three for three months.'
  else ''

define "MSM Rationale":
  if "MSM Condition" and "No HIV Test in the last year"
    then '\r\n - Men who have sex with men should be tested for HIV at least annually.' 
  else if "MSM Condition" and "On pre-exposure prophylaxis" and "No HIV Test in the last three months"
    then '\r\n - All men who have sex with men and are on pre-exposure prophylaxis should be tested for HIV every three months.'
  else ''

define "MSM Indicator":
  if "MSM Condition" then 'routine' 
    else ''


// PREGNANCY
// DH - open the collection wide to four categories as defined by the health centers
// DH - filter out anything older than 9 months

// for testing
// define pregnancyObservations:
//   HDE."Pregnancy Observations"
// define nineMonthsAgo:
//   "Reference Date" - 9 months
// end of for testing

// define "Estimated Date of Delivery":
//   // Replace this with the actual logic to determine the EDD
//   DateTime(2025, 3, 8)

define "There is a positive pregnancy test in the last 40 weeks":
  exists ( HDE."Positive Pregnancy Observations" PPO
      where PPO.effective after ( "Reference Date" - 40 weeks )
  )

define "Pregnant but no HIV test during pregnancy":
  "There is a positive pregnancy test in the last 40 weeks"
    and not "There is an HIV test after the most recent positive pregnancy test"

define "Estimated Date of Delivery":
  date from Last(HDE."Estimated Date of Delivery").value

define "First Eay of Third Trimester":
  "Estimated Date of Delivery" - 13 weeks

// define IsHigherRiskState:
//   'HI' in "HIV Higher Prevalence States and Territories"

define "State of Residence Present in Patient Record":
  Count(Patient.address.state) > 0

// troubleshooting
// define ThereLastHDEHIVTestseffective:
//   date from Last(HDE."HIV Tests").effective.value
// define ThereLastHDEEstimatedDateofDelivery:
//   date from Last(HDE."Estimated Date of Delivery").value.value

define "Lives In State with Higher HIV Prevalence":
  if "State of Residence Present in Patient Record"
    and First(Patient.address.state.value) in "HIV Higher Prevalence States and Territories" then true 
    else false

define "There is an HIV test during the third trimester":
  exists ( HDE."Estimated Date of Delivery" )
    and exists ( HDE."HIV Tests" )
    and date from Last(HDE."HIV Tests").effective on or after date from Last(HDE."Estimated Date of Delivery").value

define "Resides a high prevalence state and has not had an HIV test in the third trimester":
  "Lives In State with Higher HIV Prevalence"
    and not "There is an HIV test during the third trimester"

// define "HIV Risky Lifestyle":
//   HDE."HIV Risky Lifestyle"

define "Sex partner has HIV or uses intravenous drugs and no HIV test done in third trimester":
  exists HDE."HIV Risky Lifestyle"
    and not "There is an HIV test during the third trimester"

// define "Intravenous Drug User":
//    HDE."Intravenous Drug User"

define "Intravenous drug user and no HIV test done in third trimester":
  exists HDE."Intravenous Drug User"
    and not "There is an HIV test during the third trimester"

define "Patient who exchanges sex for money or drugs and no HIV test done in third trimester":
  exists HDE."Exchanges Sex for Drugs or Money"
    and not "There is an HIV test during the third trimester"

define "Multiple Sex Partners":
  HDE."Multiple Sex Partners"

define "Patient with multiple partners and no HIV test done in third trimester":
  exists HDE."Multiple Sex Partners"
    and not "There is an HIV test during the third trimester"

define "Patient with a new sex partner during pregnancy and no HIV test done in third trimester":
  exists HDE."New Sex Partner"
    and not "There is an HIV test during the third trimester"

define "No state of residence on record and no HIV test done in third trimester":
  not "State of Residence Present in Patient Record"
    and not "There is an HIV test during the third trimester"

define "Pregnant Condition":
  if not "Active diagnosis of HIV"
    and (
      "Pregnant but no HIV test during pregnancy"
      or "Resides a high prevalence state and has not had an HIV test in the third trimester"
      or "No state of residence on record and no HIV test done in third trimester"
      or "Intravenous drug user and no HIV test done in third trimester"
      or "Patient who exchanges sex for money or drugs and no HIV test done in third trimester"
      or "Patient with multiple partners and no HIV test done in third trimester"
      or "Sex partner has HIV or uses intravenous drugs and no HIV test done in third trimester"
      or "Patient with a new sex partner during pregnancy and no HIV test done in third trimester"
      )
  then true 
  else false

define "Pregnant Recommendation":
  if "Pregnant Condition" then
    case
      when "Pregnant but no HIV test during pregnancy" 
        then '\r\n - This patient has not been tested for HIV during pregnancy.' 
      when "Resides a high prevalence state and has not had an HIV test in the third trimester" 
        then '\r\n - This patient resides in a high prevalence state and has not been tested for HIV in the third trimester.' 
      when "No state of residence on record and no HIV test done in third trimester" 
        then '\r\n - The state of residence of this patient is unknown and she has not been tested for HIV in the third trimester.' 
      when "Intravenous drug user and no HIV test done in third trimester" 
        then '\r\n - This patient uses intravenous drugs and has not been tested for HIV in the third trimester.' 
      when "Patient who exchanges sex for money or drugs and no HIV test done in third trimester" 
        then '\r\n - This patient exchanges sex for money or drugs and has not been tested for HIV in the third trimester.' 
      when "Patient with multiple partners and no HIV test done in third trimester" 
        then '\r\n - This patient has multiple partners and has not been tested for HIV in the third trimester.' 
      when "Sex partner has HIV or uses intravenous drugs and no HIV test done in third trimester" 
        then '\r\n - This patient\'s sex partner has HIV or uses intravenous drugs and she has not been tested for HIV in the third trimester.' 
      when "Patient with a new sex partner during pregnancy and no HIV test done in third trimester" 
        then '\r\n - This patient has a new sex partner since becoming pregnant and not been tested in the third trimester.' 
      else ''
    end
  else ''

define "Pregnant Rationale":
  if "Pregnant Condition" then 
    case 
      when not "There is an HIV test after the most recent positive pregnancy test"
        then '\r\n - All pregnant women should undergo HIV testing as part of routine prenatal care.' 
      when "Resides a high prevalence state and has not had an HIV test in the third trimester" 
        then '\r\n - All pregnant women who reside in a high prevalence state should have a repeat HIV test in the third trimester.' 
      when "No state of residence on record and no HIV test done in third trimester" 
        then '\r\n - All pregnant women who reside in a high prevalence state should have a repeat HIV test in the third trimester. If no state of residence is recorded, a high prevalence state is assumed.' 
      when "Intravenous drug user and no HIV test done in third trimester" 
        then '\r\n - All pregnant women who use intravenous drugs should have a repeat HIV test in the third trimester.' 
      when "Patient who exchanges sex for money or drugs and no HIV test done in third trimester" 
        then '\r\n - All pregnant women who exchange sex for money or drugs should have a repeat HIV test in the third trimester.' 
      when "Patient with multiple partners and no HIV test done in third trimester" 
        then '\r\n - All pregnant women who have multiple partners should have a repeat HIV test in the third trimester.' 
      when "Sex partner has HIV or uses intravenous drugs and no HIV test done in third trimester" 
        then '\r\n - All pregnant women whose sex partner has HIV or uses intravenous drugs should have a repeat HIV test in the third trimester.' 
      when "Patient with a new sex partner during pregnancy and no HIV test done in third trimester" 
        then '\r\n - All pregnant women who have a new sex partner while pregnant should have a repeat HIV test in the third trimester.' 
      else ''
    end
  else ''


define "Pregnant Indicator":
  if "Pregnant Condition" then 'routine' 
    else ''

// SEEKING TREATMENT


define "Seeking STD Treatment Condition":
  if ( not "Active diagnosis of HIV"
      and "Patient is Seeking Treatment for an STD"
  ) then true 
    else false

define "Seeking STD Treatment Recommendation":
  if "Seeking STD Treatment Condition" then ( if "Over 3 Months has Passed Since Previous HIV Screening" then '\r\n - Patient is seeking treatment for an STD and more than three months have passed.' 
      else ''
  )
  // else 'HIV Screening Not Recommended at this time. It has been ' + ToString("Days Since Previous HIV Screening") + ' days since last HIV Screening.'
  
    else ''

define "Seeking STD Treatment Rationale":
  if "Seeking STD Treatment Condition" then '\r\n - All patients seeking treatment for STDs - including all patients attending an STD clinic -- should be tested for HIV at each visit for a new complaint.' 
    else ''

define "Seeking STD Treatment Indicator":
  if "Seeking STD Treatment Condition" then 'routin' 
    else ''


/* RISK Level Actions */ // DH temporarily take this out



define "Risk Level Condition": // true if the other four Conditions are false
  
  if ( not "Active diagnosis of HIV"
  // and (
  //   "Never Tested Condition" is false
  //   and "MSM Condition" is false
  //   and "Pregnant Condition" is false
  //   and "Seeking STD Treatment Condition" is false
  //   and "Tuberculosis Condition" is false
  //   // now the actual risk level conditions
      and ( ( "Patient is at High Risk for HIV"
            and "Over 3 Months has Passed Since Previous HIV Screening"
        )
          or ( "Patient is at Moderate Risk for HIV"
              and "Over a Year has Passed Since Previous HIV Screening"
          )
      )
  ) then true 
    else false

define "Risk Level Recommendation":
  if "Patient is at High Risk for HIV"
    and "Over 3 Months has Passed Since Previous HIV Screening" then 'HIV Screening Recommended due to patient being at High Risk for HIV and over three months have passed since previous screening.' 
    else if "Patient is at Moderate Risk for HIV"
    and "Over a Year has Passed Since Previous HIV Screening" then 'HIV Screening Recommended due to patient being at Moderate Risk for HIV and over a Year has passed since previous screening.'
  // else if "Patient is at No Risk for HIV" then 'HIV Screening Not Recommended due to patient being at No Risk for HIV.'
  // else if "Patient is at Low Risk for HIV" then 'HIV Screening Not Recommended due to patient being at Low Risk for HIV.'
  // else 'HIV Screening Not Recommended at this time. It has been ' + ToString("Days Since Previous HIV Screening") + ' days since last HIV Screening.'
  
  
  
    else ''

/* Risk Level Rational based on Recommendation Option (References to CDC Recommendations) */


define "Risk Level Rationale":
  if "Patient is at High Risk for HIV" then 'Health-care providers should subsequently test all persons likely to be at high risk for HIV at least every 3 months. Persons likely to be at high risk include persons with problems related to drug abuse, injection-drug users and their sex partners, persons who exchange sex for money or drugs, sex partners of HIV-infected persons, and MSM or heterosexual persons who themselves or whose sex partners have had more than one sex partner since their most recent HIV test.' 
    else if "Patient is at Moderate Risk for HIV" then 'Health-care providers should subsequently test all persons likely to be at moderate risk for HIV at least annually. Persons likely to be at moderate risk include MSM, Transgender Persons, and Gay or Bisexual Men who are sexually active and have sex with other men.'
  // else if "Patient is at No Risk for HIV" then 'The Task Force made no recommendation for or against routinely screening asymptomatic adults and adolescents with no identifiable risk factors for HIV. The Task Force concluded that such screening would detect additional patients with HIV, but the overall number would be limited, and the potential benefits did not clearly outweigh the burden on primary care practices or the potential harms of a general HIV screening program.'
  // else '\r\n - In low prevalence settings, in which the majority of clients are at minimal risk, targeted HIV testing on the basis of risk screening was considered more feasible for identifying limited numbers of HIV-infected persons. The Task Force concluded that such screening would detect additional patients with HIV, but the overall number would be limited, and the potential benefits did not clearly outweigh the burden on primary care practices or the potential harms of a general HIV screening program.'
  
  
    else ''

// define "Risk Level Indicator Status":
//   if "Patient is at High Risk for HIV" then "Stat"
//   else if "Patient is at Moderate Risk for HIV" then "Asap"
//   else if "Patient is at No Risk for HIV" then "Routine"
//   else "Routine"

//troubleshooting
// define lastHdeHivTestsEffective:
//   Last(HDE."HIV Tests").effective.value
// define lastHdeTuberculosisDiagnosisOnset:
//   Last(HDE."Tuberculosis diagnosis").onset.value
// troubleshooting

define HivTestOnOrBeforeTbDiagnosis:
  Last(HDE."HIV Tests").effective on or before Last(HDE."Tuberculosis diagnosis").onset

define "Tuberculosis Condition":
  if ( not "Active diagnosis of HIV"
      and "Active diagnosis of Tuberculosis?"
      and ( not exists HDE."HIV Tests"
          or ( exists HDE."HIV Tests"
              and Last(HDE."HIV Tests").effective on or before Last(HDE."Tuberculosis diagnosis").onset
          )
      )
  ) then true 
    else false

define "Tuberculosis Recommendation":
  if "Tuberculosis Condition" then '\r\n - This patient has not been tested for HIV since they were diagnosed with tuberculosis.' 
    else ''
  // ToString(exists(HDE."Tuberculosis diagnosis")) // This line was to expressly pass a cql-expression to a CardPlan


define "Tuberculosis Rationale":
  if "Tuberculosis Condition" then '\r\n - All patients who are about to start tuberculosis treatment should first have an HIV Test.' 
    else ''

define "Tuberculosis Indicator":
  if "Tuberculosis Condition" then 'routine' 
    else ''

define "HIV Test Condition":
  if ( "Never Tested Condition"
      or "MSM Condition"
      or "Pregnant Condition"
      or "Seeking STD Treatment Condition"
      or "Risk Level Condition"
      or  // sometimes evaluates to null
      "Tuberculosis Condition"
  ) then true 
    else false

define "HIV Test Recommendation": // 'Recommend HIV Test'
  
  "Never Tested Recommendation" + "MSM Recommendation" + "Pregnant Recommendation" + "Seeking STD Treatment Recommendation" +
  // '\r\n- ' + "Risk Level Rationale" or  // sometimes evaluates to null
  "Tuberculosis Recommendation"

define "HIV Test Rationale":
  "Never Tested Rationale" + "MSM Rationale" + "Pregnant Rationale" + "Seeking STD Treatment Rationale" +
  // '\r\n- ' + "Risk Level Rationale" or  // sometimes evaluates to null
  "Tuberculosis Rationale"

define "HIV Test Indicator":
  if "HIV Test Condition" then 'routine' 
    else ''

// define "Exclusion Reason":
//   if "Active diagnosis of HIV" then ( 'Patient was excluded from HIV Screening ' + ( if not "Patient is between 13 and 64 years old" then 'due to not being between the ages of 13 and 64.' 
//         else if "Active diagnosis of HIV" then 'due to the patient already having been diagnosed with HIV.' 
//         else ''
//     )
//   ) 
//     else ''

/* HIV Screening Workflow */
// Patient Visit Occurred

define "Patient Encounter":
  Last((HC.QualifiedEncounters(HDE."Encounter Type"
      union HDE."Pregnancy Encounters"
      union HDE."Third Trimester Encounters")) PatientEncounter
      sort by 
      end of period
  )

/* before  .
/* Determine Patient Characteristics and Testing Criteria */
// define "Patient is between 13 and 64 years old":
//   AgeInYearsAt(end of "Patient Encounter".period) >= 13
//   and AgeInYearsAt(end of "Patient Encounter".period) <= 64

define "Age":
  AgeInYearsAt("Reference Date")

/* after
/* Determine Patient Characteristics and Testing Criteria */


define "Patient is between 13 and 64 years old":
  AgeInYearsAt("Reference Date") >= 13
    and AgeInYearsAt("Reference Date") <= 64

// define "Active Diagnosis of HIV During Patient Visit":
//   ( Last((HC.QualifiedConditions(HDE."HIV Diagnosis")) HIVDiagnosis
//       sort by 
//       end of FC.ToInterval(abatement)
//   ) ) HIVDiagnosis
//     with "Patient Encounter" PatientEncounter
//       such that FC.ToPrevalenceInterval ( HIVDiagnosis ) overlaps PatientEncounter.period

define "HIV Screening Test": // DH: as of last encounter
  // (
  
  
  HC.QualifiedObservations ( HDE."HIV Tests" )
    union HC.QualifiedObservations ( HDE."Previous HIV Screening" ) // How does this fit in the logic? Where is its `status` attribute?
  // ) HIVScreening
  //   with "Patient Encounter" PatientEncounter
  //     such that FC.ToInterval(HIVScreening.effective) before PatientEncounter.period





define "Patient has had an HIV Test": //DH: as of last encounter
  
  exists ( "HIV Screening Test" )

define "Previous HIV Screening Test": // DH: originally meaning `previous to most recent encouter`. Now; `previous to Reference Date
  // from
  
  
  ( Last("HIV Screening Test" HIVTest
      sort by effective
  ) ) MostRecentHIVTest
  // "Patient Encounter" PatientEncounter
  //   where FC.ToInterval(MostRecentHIVTest.effective) before PatientEncounter.period



define "Days Since Previous HIV Screening":
  "Previous HIV Screening Test" HIVTest
    // return duration in days between end of FC.ToInterval(HIVTest.MostRecentHIVTest.effective) and end of HIVTest.PatientEncounter.period
    
    return duration in days between HIVTest.effective and "Reference Date"

define "Over a Year has Passed Since Previous HIV Screening":
  "Previous HIV Screening Test" HIVTest
    // return (duration in years between end of FC.ToInterval(HIVTest.MostRecentHIVTest.effective) and end of HIVTest.PatientEncounter.period) >= 1
    // DH: don't need no stinking encounters.
    
    
    return ( duration in years between HIVTest.effective and "Reference Date" >= 1 )

define "Over 3 Months has Passed Since Previous HIV Screening":
  "Previous HIV Screening Test" HIVTest
    // return (duration in months between end of FC.ToInterval(HIVTest.MostRecentHIVTest.effective) and end of HIVTest.PatientEncounter.period) >= 3
    
    return ( duration in months between HIVTest.effective and "Reference Date" >= 3 )

define "On pre-exposure prophylaxis":
  exists HDE."Prep Medication Prescriptions"
    // union HC.QualifiedMedicationDispenses ( HDE."Prep Dispensed Medications" )
    // union HC.QualifiedObservations ( HDE."Previous experience with PREP" ) ) PrEP

/* Determine Patient's Category (gender, pregnancy, MSM, sexual activity, etc) */

define "Patient is Male":
  if Patient.gender = 'male' then true 
  else false

define "Patient is Female":
  if Patient.gender = 'female' then true 
    else false

define "Patient is Transgender":
  HDE."Gender Identity" in Cx."Transgender"

define "Active diagnosis of Tuberculosis?":
  exists HDE."Tuberculosis diagnosis"
//   exists [Condition] c where c in Cx."TB"

define "Active diagnosis of HIV":
  exists HDE."HIV Diagnosis"

//   exists [Condition] c where c in Cx."TB"

// define "anyConditionValue":
//   [Condition] C return C.code.coding.code.value

// define "Patient is Gay or Bisexual":
//       HDE."Sexual Orientation".coding.code in Cx."Gay Or Bisexual"

// DH: This one is never used
// define "Patient is Pregnant":
//   exists(
//     (HC.QualifiedConditions(HDE."Pregnancy Conditions")) Pregnancy
//       with "Patient Encounter" PatientEncounter
//         such that FC.ToPrevalenceInterval(Pregnancy) overlaps PatientEncounter.period
//   )

/* Determine Patient's Risk Level (High Risk, Moderate Risk, No Risk, Low Risk) */
// Predominantly based off elements built from the risk-factors questionnaire
// RISKS: STIs, Injection Drug Use, Sex partner has HIV, Sex Exchanged for Drugs/Money, More than 1 Partner since previous screening (for themselves or their partners), Drug abuse

/* 1. Recommend Screening 3 months (High Risk - CDC Risk Factors)
    2. Recommend Screening Annually (Moderate Risk - SOGI Risk Factors)
    3. No Recommendation Screening (No Risk) / Low Risk
    4. Recommend Screening Custom Periods (3 months based on specific risk factor -- sexually active MSM w/ prep, etc)
      // MSM / Pregnancy / CDC Recommendation
*/

/* HIGH RISK */
// High Risk -- Other STIs

define "Active Diagnosis of HCV During Patient Visit":
  ( ( Last((HC.QualifiedConditions(HDE."Hepatitis C Diagnosis")) HCVDiagnosis
        sort by 
        end of FC.ToInterval(abatement)
    ) ) HCVDiagnosis
      with "Patient Encounter" PatientEncounter
        such that FC.ToPrevalenceInterval ( HCVDiagnosis ) overlaps PatientEncounter.period
  ) is not null
    or exists ( ( HC.QualifiedObservations ( HDE."Patient Diagnosed with HCV" ) ) HCVObserved
        with "Patient Encounter" PatientEncounter
          such that FC.ToInterval ( HCVObserved.effective ) overlaps PatientEncounter.period
    )

define "Active Diagnosis of Syphilis During Patient Visit":
  ( ( Last((HC.QualifiedConditions(HDE."Syphilis Diagnosis")) SyphilisDiagnosis
        sort by 
        end of FC.ToInterval(abatement)
    ) ) SyphilisDiagnosis
      with "Patient Encounter" PatientEncounter
        such that FC.ToPrevalenceInterval ( SyphilisDiagnosis ) overlaps PatientEncounter.period
  ) is not null
    or exists ( ( HC.QualifiedObservations ( HDE."Patient Diagnosed with Syphilis" ) ) SyphilisObserved
        with "Patient Encounter" PatientEncounter
          such that FC.ToInterval ( SyphilisObserved.effective ) overlaps PatientEncounter.period
    )

define "Active Diagnosis of Gonorrhea During Patient Visit":
  ( ( Last((HC.QualifiedConditions(HDE."Gonorrhea Diagnosis")) GonorrheaDiagnosis
        sort by 
        end of FC.ToInterval(abatement)
    ) ) GonorrheaDiagnosis
      with "Patient Encounter" PatientEncounter
        such that FC.ToPrevalenceInterval ( GonorrheaDiagnosis ) overlaps PatientEncounter.period
  ) is not null
    or exists ( ( HC.QualifiedObservations ( HDE."Patient Diagnosed with Gonorrhea" ) ) GonorrheaObserved
        with "Patient Encounter" PatientEncounter
          such that FC.ToInterval ( GonorrheaObserved.effective ) overlaps PatientEncounter.period
    )

define "Active Diagnosis of Chlamydia During Patient Visit":
  ( ( Last((HC.QualifiedConditions(HDE."Chlamydia Diagnosis")) ChlamydiaDiagnosis
        sort by 
        end of FC.ToInterval(abatement)
    ) ) ChlamydiaDiagnosis
      with "Patient Encounter" PatientEncounter
        such that FC.ToPrevalenceInterval ( ChlamydiaDiagnosis ) overlaps PatientEncounter.period
  ) is not null
    or exists ( ( HC.QualifiedObservations ( HDE."Patient Diagnosed with Chlamydia" ) ) ChlamydiaObserved
        with "Patient Encounter" PatientEncounter
          such that FC.ToInterval ( ChlamydiaObserved.effective ) overlaps PatientEncounter.period
    )

define "Patient is at High Risk Due to a STD":
  "Active Diagnosis of HCV During Patient Visit"
    or "Active Diagnosis of Syphilis During Patient Visit"
    or "Active Diagnosis of Gonorrhea During Patient Visit"
    or "Active Diagnosis of Chlamydia During Patient Visit"

// High Risk -- Injection Drug Use
// NOTE: What is considered an Active Time Period for Injection Drug Use?



define "Patient is at High Risk Due to Injection Drug Use":
  ( ( Last((HC.QualifiedProcedures(HDE."Drug Rehabilitation")
        union HC.QualifiedObservations(HDE."Injection Findings")
        union HC.QualifiedConditions(HDE."Injection Drug Use Diagnosis")
        // union HC.QualifiedMedicationStatements(HDE."Injection Drug Use")
        union HC.QualifiedObservations(HDE."Patient has used Injection Drugs")) InjectionDrugUse
        return Tuple {
          resource: InjectionDrugUse,
          IDUTiming: Coalesce(
            end of FC.ToInterval(InjectionDrugUse.performed), 
            end of FC.ToInterval(InjectionDrugUse.effective), 
            end of FC.ToPrevalenceInterval(InjectionDrugUse)
          )
        }
        sort by IDUTiming
    ).resource ) InjectionDrugUse
      with "Patient Encounter" PatientEncounter
        such that Coalesce(FC.ToInterval(InjectionDrugUse.performed), FC.ToInterval(InjectionDrugUse.effective), FC.ToPrevalenceInterval(InjectionDrugUse)) overlaps PatientEncounter.period
  ) is not null

//High Risk -- Drug Abuse


define "Patient is at High Risk Due to Drug Abuse":
  "Patient Has High Degree Of Problems Related To Drug Abuse"

// High Risk -- Partner with HIV


define "Patient is at High Risk Due to Sexual Partner having HIV":
  exists ( ( HC.QualifiedObservations ( HDE."Sexual Activity - Partners HIV History" ) ) HIVPartnerHistory
      with "Patient Encounter" PatientEncounter
        such that FC.ToInterval ( HIVPartnerHistory.effective ) overlaps PatientEncounter.period
  )

// High Risk -- Sex Exchanged for Drugs/Money


define "Patient is at High Risk Due to exchanging sex for money or drugs":
  exists ( ( HC.QualifiedObservations ( HDE."Sexual Activity - Exchanged for Sex" ) ) SexExchanged
      with "Patient Encounter" PatientEncounter
        such that FC.ToInterval ( SexExchanged.effective ) overlaps PatientEncounter.period
  )

// DH: For testing
// define HIVScreeningInterval:
//   FC.ToInterval(((Last(
//         (
//           HC.QualifiedObservations(HDE."HIV Tests") //QualifiedObservations: status = 'preliminary' 'final' 'amended' or 'corrected'
//           union HC.QualifiedObservations(HDE."Previous HIV Screening") // How does this fit in the logic? Where is its `status` attribute?
//         ) HIVScreening
//         sort by end of FC.ToInterval(effective) //DH: The result of will be a 'unit interval'. How is that diffenent than just
//     )) HIVScreening).effective)

// DH: for testing
// define NumberOfPartnersInterval:
//   (
//         HC.QualifiedObservations(HDE."Sexual Activity - Number of Partners") // DH: Number of Partners seems to equate to Multiple Partners
//         union HC.QualifiedObservations(HDE."Sexual Activity - Partners Number of Partners")
//       ) NumberOfPartners

// High Risk -- Multiple Sex Partners since previous HIV Screening for Patient or their partner
// DH: note that relies on timestamps of HIV Test observation and Multiple Partners observation. For example if
// your test case has a negative HIV test and then a fresh observation of Multiple Partners, then they are
// once again marked high risk.
// You might think for practical puposes once a person has multiple partners that that designation might not
// be changed i.e. the patient might be considered forever high risk.
// DH: there's some redundany here. HC.QualifiedObservations limits status = 'preliminary' 'final' 'amended' or 'corrected'
// but in "Sexual Activity - Number of Partners" it is already limited to 'final', 'amended', 'corrected'      

define "Patient is at High Risk Due to Multiple Sex Partners since last screening":
  ( ( Last((HC.QualifiedObservations(HDE."HIV Tests") //QualifiedObservations: status = 'preliminary' 'final' 'amended' or 'corrected'
        
        union HC.QualifiedObservations(HDE."Previous HIV Screening") // How does this fit in the logic? Where is its `status` attribute?
      ) HIVScreening
        sort by 
        end of FC.ToInterval(effective) //DH: The result of will be a 'unit interval'. How is that diffenent than just 
    
    ) ) HIVScreening
      with ( HC.QualifiedObservations ( HDE."Sexual Activity - Number of Partners" ) // DH: Number of Partners seems to equate to Multiple Partners
        
        union HC.QualifiedObservations ( HDE."Sexual Activity - Partners Number of Partners" ) ) NumberOfPartners
        such that FC.ToInterval ( HIVScreening.effective ) before FC.ToInterval ( NumberOfPartners.effective )
  ) is not null

define "Patient is at High Risk for HIV":
  "Patient is at High Risk Due to a STD"
    or "Patient is at High Risk Due to Injection Drug Use"
    or "Patient is at High Risk Due to Drug Abuse"  //score of 6 through 10 on DAST
    
    or "Patient is at High Risk Due to Sexual Partner having HIV"
    or "Patient is at High Risk Due to exchanging sex for money or drugs"
    or "Patient is at High Risk Due to Multiple Sex Partners since last screening"

// define "x":
// false or false or null or false or false or false

/* MODERATE RISK */
// Sexually active MSM, Transgender patient sexually active with men, Gay and bisexual men unless documented not sexually active

// Moderate Risk -- Any sexually active MSM

define "Has sex with men":
  if exists HDE."Has sex with men"
  then true
  else false

// Moderate Risk -- Transgender patients sexually active with men

define "Transgender Patient Sexually Active With Men":
  if "Patient is Transgender" then ( exists ( ( HC.QualifiedObservations ( HDE."Has sex with men" ) ) MSMObserved
        with "Patient Encounter" PatientEncounter
          such that FC.ToInterval ( MSMObserved.effective ) overlaps PatientEncounter.period
    )
  ) 
    else false

// Moderate Risk -- All gay or bisexual men unless documented not sexually active

define "Male and (Gay or Bisexual) Patient Not Documented Sexually Inactive":
  "Patient is Male"
    and "Patient is Gay or Bisexual"
    and not "Patient is Documented Sexually Inactive"

define "Patient is at Moderate Risk for HIV":
  "Patient is Male" and "Has sex with men"
  or "Transgender Patient Sexually Active With Men"
  or "Male and (Gay or Bisexual) Patient Not Documented Sexually Inactive"


/* No Risk */
// Not Sexually Active

define "Patient is Documented Sexually Inactive":
  ( ( Last((HC.QualifiedObservations(HDE."Sexual Activity - Past Year")
        union HC.QualifiedObservations(HDE."Sexual Activity - History")
        union HC.QualifiedObservations(HDE."Has sex with men")
        union HC.QualifiedObservations(HDE."Sexual Activity - Women")) SexualHistory
        where Coalesce(Lower(SexualHistory.value as string) in { 'no' }, SexualHistory.value as boolean = false)
        sort by Coalesce(effective, issued)
    ) ) SexualHistory
      with "Patient Encounter" Encounter
        such that Coalesce(FC.ToInterval(SexualHistory.effective), FC.ToInterval(SexualHistory.issued)) during Encounter.period
  ) is not null

define "Patient is at No Risk for HIV": // Of course nobody is ever at No Risk. I'm just sayin'. 
  
  "Patient is Documented Sexually Inactive" 


/* LOW RISK */
// Not sexually active

define "Patient is at Low Risk for HIV":
  not "Patient is at High Risk for HIV"  // risky behaviors
    
    and not "Patient is at Moderate Risk for HIV" // genetic males sexually active with genetic males
    
    and not "Patient is at No Risk for HIV"  // i.e. not "Patient is Documented Sexually Inactive"

// DH: Testing testing

define PatientEncounterPeriodStart:
  start of ( "Patient Encounter".period )

define PatientEncounterPeriodEnd:
  end of ( "Patient Encounter".period )

define SeekingTreatmentDate:
  ( HC.QualifiedObservations ( HDE."Seeking STD Treatment" ) ).effective.value

/* Women & Men Workflow */
// All Women and Men between the ages 13-64 and/or those who are seeking treatment for an STD

define "Patient is Seeking Treatment for an STD":
  exists ( ( HC.QualifiedObservations ( HDE."Seeking STD Treatment" ) ) SeekingTreatment
      with "Patient Encounter" PatientEncounter
        such that FC.ToInterval ( SeekingTreatment.effective ) overlaps PatientEncounter.period
  )

/* Pregnant Women Workflow */
// All Women should be screened at Initial Prenatal Visit
// All women should be retested in the third trimester if they're high risk
// NOTE: This definition implementation is naive and does not take into effect multiple pregnancies. Consider use of an EpisodeOfCare resource.

define "Patient is at First Prenatal Visit":
  ( ( First((HC.QualifiedEncounters(HDE."Pregnancy Encounters")) PregnancyEncounter
        sort by 
        end of period
    ) ) PregnancyEncounter
      with "Patient Encounter" PatientEncounter
        such that PregnancyEncounter.id = PatientEncounter.id
  ) is not null

// define "Patient is in Third Trimester of Pregnancy":
//   (
//     (Last(
//       (HC.QualifiedEncounters(HDE."Third Trimester Encounters")) ThirdTrimesterEncounter
//     sort by end of period
//     )) ThirdTrimesterEncounter
//       // with "Patient Encounter" PatientEncounter
//       //   such that ThirdTrimesterEncounter.id = PatientEncounter.id
//   ) is not null

// define "Patient is High Risk in Third Trimester of Pregnancy":
//   "Patient is at High Risk for HIV"
//   and "Patient is in Third Trimester of Pregnancy"

/* MSM (Men who have sex with men) */
// At Least Annually for sexually active MSM if HIV status isn't positive and if patient/partner has had more than 1 partner since previous screening
// For sexually active MSM Tests should occur every 3 months if the patient has experienced prep

define "Patient is a sexually active MSM without HIV":
  "Patient is Male" and "Has sex with men"
  and not "Active diagnosis of HIV"

define "Patient is a sexually active MSM with Multiple Sex Partners":
  "Patient is a sexually active MSM without HIV"
    and "Patient is at High Risk Due to Multiple Sex Partners since last screening"

// define "Patient is a sexually active MSM who should be Screened Annually":
//   "Patient is a sexually active MSM with Multiple Sex Partners"
//     and "Over a Year has Passed Since Previous HIV Screening"

define "Patient is a sexually active MSM who should be Screened Every 3 Months":
  "Patient is a sexually active MSM without HIV"
    and "On pre-exposure prophylaxis"
    and "Over 3 Months has Passed Since Previous HIV Screening"


/* Drug Abuse Screning Test (DAST-10) Questionnaire */
// Score acquired either by tallying codes for DAST-10 questions or by the value field of DAST-10 Questionnaire or result codes
// High Risk: >= 6
// Moderate Risk: 3 - 5
// Low Risk: 1 - 2
// No Risk: 0







define "DAST 10 Result Score":
  NC.MostRecent ( HDE."DAST 10 Score" ).value.value

define "All DAST 10 Questions":
  { NC.MostRecent ( HDE."DAST 10 Question 1" ), NC.MostRecent ( HDE."DAST 10 Question 2" ), NC.MostRecent ( HDE."DAST 10 Question 3" ), NC.MostRecent ( HDE."DAST 10 Question 4" ), NC.MostRecent ( HDE."DAST 10 Question 5" ), NC.MostRecent ( HDE."DAST 10 Question 6" ), NC.MostRecent ( HDE."DAST 10 Question 7" ), NC.MostRecent ( HDE."DAST 10 Question 8" ), NC.MostRecent ( HDE."DAST 10 Question 9" ), NC.MostRecent ( HDE."DAST 10 Question 10" ) }

define "Latest DAST 10 Questions Date":
  date from start of FC.ToInterval ( NC.MostRecent ( "All DAST 10 Questions" ).effective )

define "DAST 10 Questions Score":
  Count("All DAST 10 Questions" question
      where question.value as boolean is true
  )

define "Latest DAST 10 Screening Date":
  date from start of FC.ToInterval ( NC.MostRecent ( HDE."DAST 10 Score"
    union "All DAST 10 Questions" ).effective )

//"Patient is at High Risk Due to a STD"


define "Patient Has High Degree Of Problems Related To Drug Abuse":
  ( "DAST 10 Result Score" in "DAST 10 High Risk Score" )
    or ( "DAST 10 Questions Score" in "DAST 10 High Risk Score" )

// this has no apparent application


define "Patient Has Moderate Degree Of Problems Related To Drug Abuse":
  ( "DAST 10 Result Score" in "DAST 10 Moderate Risk Score" )
    or ( "DAST 10 Questions Score" in "DAST 10 Moderate Risk Score" )

define "Patient Has Low Degree Of Problems Related To Drug Abuse":
  ( "DAST 10 Result Score" in "DAST 10 Low Risk Score" )
    or ( "DAST 10 Questions Score" in "DAST 10 Low Risk Score" )

// this has no apparent application


define "Patient Has Low To Moderate Degree Of Problems Related To Drug Abuse":
  "Patient Has Low Degree Of Problems Related To Drug Abuse"
    or "Patient Has Moderate Degree Of Problems Related To Drug Abuse"

// this has no apparent application


define "Patient Has No Problems Related To Drug Abuse":
  ( "DAST 10 Result Score" in "DAST 10 No Risk Score" )
    or ( "DAST 10 Questions Score" is null )

// this has no apparent application


define "Patient Not Screened For Drug Abuse Or Screening Expired":
  ( "Latest DAST 10 Screening Date" is null )
    or ( difference in years between "Latest DAST 10 Screening Date" and Today() >= 1 )

define "DAST 10 High Risk Score":
  Interval[6, 10]

define "DAST 10 Moderate Risk Score":
  Interval[3, 5]

define "DAST 10 Low Risk Score":
  Interval[1, 2]

define "DAST 10 No Risk Score":
  Interval[0, 0]