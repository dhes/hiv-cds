const fs = require("fs");
const path = require("path");

const generateTestCases = () => {
  const variables = {
    deceased: [null, true, false, "2023-01-01"],
    active: [true, false],
    gender: ["male", "female"],
    age: ["too-young", "just-old-enough", "just-young-enough", "too-old"],
    address: [null, "HI", "VI"],
    hivPositive: [true, false],
    timelyTest: [null, "not-recent-enough", "just-recent-enough"],
  };

  const referenceDate = new Date("2024-01-01");
  const lowerAgeLimit = 13;
  const upperAgeLimit = 64;

  const calculateBirthDate = (age) => {
    const copyDate = (date) => new Date(date.getTime());

    if (age === "too-young") {
      const birthDate = copyDate(referenceDate);
      birthDate.setFullYear(referenceDate.getFullYear() - lowerAgeLimit);
      birthDate.setDate(birthDate.getDate() + 1);
      return birthDate.toISOString().split("T")[0];
    }

    if (age === "just-old-enough") {
      const birthDate = copyDate(referenceDate);
      birthDate.setFullYear(referenceDate.getFullYear() - lowerAgeLimit);
      return birthDate.toISOString().split("T")[0];
    }

    if (age === "just-young-enough") {
      const birthDate = copyDate(referenceDate);
      birthDate.setFullYear(referenceDate.getFullYear() - upperAgeLimit - 1);
      birthDate.setDate(birthDate.getDate() - 1);
      return birthDate.toISOString().split("T")[0];
    }

    if (age === "too-old") {
      const birthDate = copyDate(referenceDate);
      birthDate.setFullYear(referenceDate.getFullYear() - upperAgeLimit - 1);
      return birthDate.toISOString().split("T")[0];
    }
  };

  const calculateTestDate = (birthDate, timelyTest) => {
    const birthDateObj = new Date(birthDate);

    if (timelyTest === "not-recent-enough") {
      const testDate = new Date(birthDateObj);
      testDate.setDate(testDate.getDate() - 1);
      return testDate.toISOString().split("T")[0];
    }

    if (timelyTest === "just-recent-enough") {
      const testDate = new Date(birthDateObj);
      return testDate.toISOString().split("T")[0];
    }

    return null; // No test
  };

  const generateObservationResource = (patientId, testDate) => ({
    resourceType: "Observation",
    id: `hiv-${patientId}-obs`,
    status: "final",
    subject: {
      reference: `Patient/hiv-${patientId}`,
    },
    code: {
      coding: [
        {
          system: "http://loinc.org",
          code: "56888-1",
          display:
            "HIV 1+2 Ab+HIV1 p24 Ag [Presence] in Serum or Plasma by Immunoassay",
        },
      ],
      text: "HIV 1+2 Ab+HIV1 p24 Ag [Presence] in Serum or Plasma by Immunoassay",
    },
    effectiveDateTime: testDate,
    valueCodeableConcept: {
      coding: [
        {
          system: "http://snomed.info/sct",
          code: "260385009",
          display: "Negative (qualifier value)",
        },
      ],
      text: "Negative (qualifier value)",
    },
    interpretation: [
      {
        coding: [
          {
            system:
              "http://terminology.hl7.org/CodeSystem/v3-ObservationInterpretation",
            code: "NEG",
            display: "Negative",
          },
        ],
      },
    ],
  });

  const generateConditionResource = (patientId) => ({
    resourceType: "Condition",
    id: `hiv-${patientId}-cond`,
    clinicalStatus: {
      coding: [
        {
          system: "http://terminology.hl7.org/CodeSystem/condition-clinical",
          code: "active",
          display: "Active",
        },
      ],
    },
    verificationStatus: {
      coding: [
        {
          system: "http://terminology.hl7.org/CodeSystem/condition-ver-status",
          code: "confirmed",
          display: "Confirmed",
        },
      ],
    },
    category: [
      {
        coding: [
          {
            system: "http://terminology.hl7.org/CodeSystem/condition-category",
            code: "problem-list-item",
            display: "Problem List Item",
          },
        ],
      },
    ],
    code: {
      coding: [
        {
          system: "http://hl7.org/fhir/sid/icd-10",
          code: "Z21",
          display:
            "Asymptomatic human immunodeficiency virus [HIV] infection status",
        },
      ],
      text: "Asymptomatic HIV infection",
    },
    subject: {
      reference: `Patient/hiv-${patientId}`,
    },
    onsetDateTime: "2023-01-01",
    recordedDate: "2023-01-15",
  });

  const isActionRequired = (deceased, active, age, hivPositive, timelyTest) => {
    if (
      hivPositive ||
      deceased ||
      !active ||
      age === "too-young" ||
      age === "too-old" ||
      timelyTest === "just-recent-enough"
    ) {
      return false;
    }
    return true;
  };

  const generateId = (
    deceased,
    active,
    gender,
    age,
    address,
    hivPositive,
    timelyTest
  ) => {
    const deceasedPart =
      deceased === null
        ? "f"
        : deceased === true
        ? "t"
        : deceased === false
        ? "f"
        : "d";
    const addressPart = address === null ? "none" : address;
    const timelyTestPart =
      timelyTest === null
        ? "nul"
        : timelyTest === "not-recent-enough"
        ? "nre"
        : "jre";
    const agePart = {
      "too-young": "ty",
      "just-old-enough": "joe",
      "just-young-enough": "jye",
      "too-old": "to",
    }[age];

    return `${deceasedPart}-${active ? "a" : "i"}-${
      gender[0]
    }-${agePart}-${addressPart}-${
      hivPositive ? "pos" : "neg"
    }-${timelyTestPart}`;
  };

  const generateDescription = (
    age,
    deceased,
    active,
    gender,
    address,
    hivPositive,
    timelyTest
  ) => {
    const state = address === "HI" ? "HI" : address === "VI" ? "VI" : "nowhere";
    const testDescription =
      timelyTest === null
        ? "no test"
        : timelyTest === "not-recent-enough"
        ? "too-old test"
        : "recent enough test";
    return `${
      deceased === null || deceased === false ? "living" : "deceased"
    } ${active ? "active" : "inactive"} ${gender} ${age} from ${state} ${
      hivPositive ? "HIV positive" : "HIV negative"
    }, ${testDescription}`;
  };

  const testCases = [];

  variables.deceased.forEach((deceased) => {
    variables.active.forEach((active) => {
      variables.gender.forEach((gender) => {
        variables.age.forEach((age) => {
          variables.address.forEach((address) => {
            variables.hivPositive.forEach((hivPositive) => {
              variables.timelyTest.forEach((timelyTest) => {
                const birthDate = calculateBirthDate(age);
                const testDate = calculateTestDate(birthDate, timelyTest);
                const id = generateId(
                  deceased,
                  active,
                  gender,
                  age,
                  address,
                  hivPositive,
                  timelyTest
                );
                const description = generateDescription(
                  age,
                  deceased,
                  active,
                  gender,
                  address,
                  hivPositive,
                  timelyTest
                );
                const requiresAction = isActionRequired(
                  deceased,
                  active,
                  age,
                  hivPositive,
                  timelyTest
                );

                const patient = {
                  resourceType: "Patient",
                  id: `hiv-${id}`,
                  extension: [
                    {
                      url: "http://hl7.org/fhir/StructureDefinition/patient-comment",
                      valueString: description,
                    },
                    {
                      url: "http://cds.hopena.info/StructureDefinition/patient-requires-action",
                      valueString: requiresAction.toString(),
                    },
                  ],
                  identifier: [
                    {
                      system: "http://example.org/hiv-screening",
                      value: id,
                    },
                  ],
                  name: [
                    {
                      given: ["Absolutely"],
                      family: "Nobody",
                    },
                  ],
                  birthDate,
                  gender,
                  active,
                  ...(deceased === true
                    ? { deceasedBoolean: true }
                    : deceased === false
                    ? { deceasedBoolean: false }
                    : deceased
                    ? { deceasedDateTime: deceased }
                    : {}),
                  ...(address && {
                    address: [
                      {
                        use: "home",
                        state: address,
                      },
                    ],
                  }),
                };

                const testCase = {
                  id,
                  hivPositive,
                  timelyTest,
                  patient,
                  ...(hivPositive && {
                    condition: generateConditionResource(id),
                  }),
                  ...(testDate && {
                    observation: generateObservationResource(id, testDate),
                  }),
                };

                testCases.push(testCase);
              });
            });
          });
        });
      });
    });
  });

  return testCases;
};

const saveTestCases = (testCases) => {
  testCases.forEach(
    ({ id, hivPositive, timelyTest, patient, condition, observation }) => {
      const patientDir = path.join(
        "input",
        "test",
        "PlanDefinition",
        "HIVScreening",
        `hiv-${id}`,
        "Patient"
      );
      fs.mkdirSync(patientDir, { recursive: true });
      fs.writeFileSync(
        path.join(patientDir, `hiv-${id}.json`),
        JSON.stringify(patient, null, 2)
      );

      if (hivPositive) {
        const conditionDir = path.join(
          "input",
          "test",
          "PlanDefinition",
          "HIVScreening",
          `hiv-${id}`,
          "Condition"
        );
        fs.mkdirSync(conditionDir, { recursive: true });
        fs.writeFileSync(
          path.join(conditionDir, `hiv-${id}-cond.json`),
          JSON.stringify(condition, null, 2)
        );
      }

      if (observation) {
        const observationDir = path.join(
          "input",
          "test",
          "PlanDefinition",
          "HIVScreening",
          `hiv-${id}`,
          "Observation"
        );
        fs.mkdirSync(observationDir, { recursive: true });
        fs.writeFileSync(
          path.join(observationDir, `hiv-${id}-obs.json`),
          JSON.stringify(observation, null, 2)
        );
      }
    }
  );

  console.log(
    `Saved ${testCases.length} test cases to individual directories.`
  );
};

// Generate and save test cases
const testCases = generateTestCases();
saveTestCases(testCases);
