library HIVScreening

using FHIR version '4.0.1'

include FHIRCommon called FC
include FHIRHelpers version '4.0.1'
include HIVCommon called HC
include HIVConcepts called Cx
include HIVDataElements called HDE

parameter "Reference Date" DateTime  // can use values such as Now() or a date like @2024-01-01T00:00:00-10:00
  // default @2024-01-01T00:00:00-10:00 // for testing within ExecuteCQL
  default Now() 

parameter "HIV Higher Prevalence States and Territories" default { 'VI', 'MS', 'NV', 'TX', 'FL', 'LA', 'GA', 'DC' }

context Patient

define "There is an HIV test after the most recent positive pregnancy test":
  exists ( HDE."HIV Tests" )
    and Last(HDE."HIV Tests").effective > Last(HDE."Positive Pregnancy Observations").effective

define "Alive":
  case     
    when Patient.deceased = false then true  
    else false end

define Active:
  if Patient.active = true then true 
    else false

// define "Patient is Gay or Bisexual":
//   exists ( HDE."Sexual Orientation".coding ) O
//     where ( O in Cx."Gay Or Bisexual" )

define "Patient Name":
  First(First(Patient.name).given.value) + ' ' + First(Patient.name).family.value

define "Meets Inclusion Criteria":
  "Patient is between 13 and 64 years old"
    or "Patient is Seeking Treatment for an STD"

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
  '\r\n - All patients age 13 to 64 years (inclusive) should be tested for HIV at least once.' 
    else ''

define "Never Tested Indicator":
  if "Never Tested Condition" then 'routine' 
    else ''

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

define "State of Residence Present in Patient Record":
  Count(Patient.address.state) > 0

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

define "Sex partner has HIV or uses intravenous drugs and no HIV test done in third trimester":
  exists HDE."HIV Risky Lifestyle"
    and not "There is an HIV test during the third trimester"

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

define "Seeking STD Treatment Condition":
  if ( not "Active diagnosis of HIV"
      and "Patient is Seeking Treatment for an STD"
  ) then true 
    else false

define "Seeking STD Treatment Recommendation":
  if "Seeking STD Treatment Condition" then ( if "Over 3 Months has Passed Since Previous HIV Screening" then '\r\n - Patient is seeking treatment for an STD and more than three months have passed.' 
      else ''
  )
    else ''

define "Seeking STD Treatment Rationale":
  if "Seeking STD Treatment Condition" then '\r\n - All patients seeking treatment for STDs - including all patients attending an STD clinic -- should be tested for HIV at each visit for a new complaint.' 
    else ''

define "Seeking STD Treatment Indicator":
  if "Seeking STD Treatment Condition" then 'routin' 
    else ''

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
      // or "Risk Level Condition"
      "Tuberculosis Condition"
  ) then true 
    else false

define "HIV Test Recommendation": // 'Recommend HIV Test'
  
  "Never Tested Recommendation" + "MSM Recommendation" + "Pregnant Recommendation" + "Seeking STD Treatment Recommendation" +
  "Tuberculosis Recommendation"

define "HIV Test Rationale":
  "Never Tested Rationale" + "MSM Rationale" + "Pregnant Rationale" + "Seeking STD Treatment Rationale" +
  "Tuberculosis Rationale"

define "HIV Test Indicator":
  if "HIV Test Condition" then 'routine' 
    else ''

define "Patient Encounter":
  Last((HC.QualifiedEncounters(HDE."Encounter Type"
      union HDE."Pregnancy Encounters"
      union HDE."Third Trimester Encounters")) PatientEncounter
      sort by 
      end of period
  )

define "Age":
  AgeInYearsAt("Reference Date")

define "Patient is between 13 and 64 years old":
  AgeInYearsAt("Reference Date") >= 13
    and AgeInYearsAt("Reference Date") <= 64

define "HIV Screening Test": // DH: as of last encounter
  HC.QualifiedObservations ( HDE."HIV Tests" )
    union HC.QualifiedObservations ( HDE."Previous HIV Screening" ) // How does this fit in the logic? Where is its `status` attribute?
  // ) HIVScreening
  //   with "Patient Encounter" PatientEncounter
  //     such that FC.ToInterval(HIVScreening.effective) before PatientEncounter.period

define "Patient has had an HIV Test": //DH: as of last encounter
  
  exists ( "HIV Screening Test" )

define "Previous HIV Screening Test": // DH: originally meaning `previous to most recent encouter`. Now; `previous to Reference Date
  ( Last("HIV Screening Test" HIVTest
      sort by effective
  ) ) MostRecentHIVTest



define "Days Since Previous HIV Screening":
  "Previous HIV Screening Test" HIVTest
    return duration in days between HIVTest.effective and "Reference Date"

define "Over a Year has Passed Since Previous HIV Screening":
  "Previous HIV Screening Test" HIVTest
    return ( duration in years between HIVTest.effective and "Reference Date" >= 1 )

define "Over 3 Months has Passed Since Previous HIV Screening":
  "Previous HIV Screening Test" HIVTest
    return ( duration in months between HIVTest.effective and "Reference Date" >= 3 )

define "On pre-exposure prophylaxis":
  exists HDE."Prep Medication Prescriptions"

define "Patient is Male":
  if Patient.gender = 'male' then true 
  else false

define "Patient is Female":
  if Patient.gender = 'female' then true 
    else false

// define "Patient is Transgender":
//   HDE."Gender Identity" in Cx."Transgender"

define "Active diagnosis of Tuberculosis?":
  exists HDE."Tuberculosis diagnosis"

define "Active diagnosis of HIV":
  exists HDE."HIV Diagnosis"

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

define "Active Diagnosis of Gonorrhea During Patient Visit":
    exists ( ( HC.QualifiedObservations ( HDE."Patient Diagnosed with Gonorrhea" ) ) GonorrheaObserved
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
    or "Active Diagnosis of Gonorrhea During Patient Visit"
    or "Active Diagnosis of Chlamydia During Patient Visit"

define "Patient is at High Risk Due to Injection Drug Use":
  ( ( Last((HC.QualifiedProcedures(HDE."Drug Rehabilitation")
        union HC.QualifiedObservations(HDE."Injection Findings")
        union HC.QualifiedObservations(HDE."Patient has used Injection Drugs")) InjectionDrugUse
        return Tuple {
          resource: InjectionDrugUse,
          IDUTiming: Coalesce(
            end of FC.ToInterval(InjectionDrugUse.performed), 
            end of FC.ToInterval(InjectionDrugUse.effective) 
          )
        }
        sort by IDUTiming
    ).resource ) InjectionDrugUse
      with "Patient Encounter" PatientEncounter
        such that Coalesce(FC.ToInterval(InjectionDrugUse.performed), FC.ToInterval(InjectionDrugUse.effective)) overlaps PatientEncounter.period
  ) is not null

define "Patient is at High Risk Due to Sexual Partner having HIV":
  exists ( ( HC.QualifiedObservations ( HDE."Sexual Activity - Partners HIV History" ) ) HIVPartnerHistory
      with "Patient Encounter" PatientEncounter
        such that FC.ToInterval ( HIVPartnerHistory.effective ) overlaps PatientEncounter.period
  )

define "Patient is at High Risk Due to exchanging sex for money or drugs":
  exists ( ( HC.QualifiedObservations ( HDE."Sexual Activity - Exchanged for Sex" ) ) SexExchanged
      with "Patient Encounter" PatientEncounter
        such that FC.ToInterval ( SexExchanged.effective ) overlaps PatientEncounter.period
  )

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
    or "Patient is at High Risk Due to Sexual Partner having HIV"
    or "Patient is at High Risk Due to exchanging sex for money or drugs"
    or "Patient is at High Risk Due to Multiple Sex Partners since last screening"

define "Has sex with men":
  if exists HDE."Has sex with men"
  then true
  else false

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


define "Patient is at Low Risk for HIV":
  not "Patient is at High Risk for HIV"  // risky behaviors
    // and not "Patient is at Moderate Risk for HIV" // genetic males sexually active with genetic males
    and not "Patient is at No Risk for HIV"  // i.e. not "Patient is Documented Sexually Inactive"

define PatientEncounterPeriodStart:
  start of ( "Patient Encounter".period )

define PatientEncounterPeriodEnd:
  end of ( "Patient Encounter".period )

define SeekingTreatmentDate:
  ( HC.QualifiedObservations ( HDE."Seeking STD Treatment" ) ).effective.value

define "Patient is Seeking Treatment for an STD":
  exists ( ( HC.QualifiedObservations ( HDE."Seeking STD Treatment" ) ) SeekingTreatment
      with "Patient Encounter" PatientEncounter
        such that FC.ToInterval ( SeekingTreatment.effective ) overlaps PatientEncounter.period
  )

define "Patient is at First Prenatal Visit":
  ( ( First((HC.QualifiedEncounters(HDE."Pregnancy Encounters")) PregnancyEncounter
        sort by 
        end of period
    ) ) PregnancyEncounter
      with "Patient Encounter" PatientEncounter
        such that PregnancyEncounter.id = PatientEncounter.id
  ) is not null

define "Patient is a sexually active MSM without HIV":
  "Patient is Male" and "Has sex with men"
  and not "Active diagnosis of HIV"

define "Patient is a sexually active MSM with Multiple Sex Partners":
  "Patient is a sexually active MSM without HIV"
    and "Patient is at High Risk Due to Multiple Sex Partners since last screening"

define "Patient is a sexually active MSM who should be Screened Every 3 Months":
  "Patient is a sexually active MSM without HIV"
    and "On pre-exposure prophylaxis"
    and "Over 3 Months has Passed Since Previous HIV Screening"

