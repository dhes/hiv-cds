const fs = require('fs');
const path = require('path');

const generateTestCases = () => {
  const variables = {
    deceased: [null, true, false, "2023-01-01"],
    active: [true, false],
    gender: ["male", "female"],
    age: ["too-young", "just-old-enough", "just-young-enough", "too-old"],
    address: [null, "HI", "VI"],
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

  const isActionRequired = (deceased, active, age, isPositive) => {
    if (isPositive) return false; // Patients with HIV don't require screening
    if (deceased || !active || age === "too-young" || age === "too-old") {
      return false;
    }
    return true;
  };

  const generateId = (deceased, active, gender, age, address, isPositive) => {
    const deceasedPart = deceased === null ? "f" : deceased === true ? "t" : deceased === false ? "f" : "d";
    const addressPart = address === null ? "none" : address;
    return `${deceasedPart}-${active ? "t" : "f"}-${gender[0]}-${age}-${addressPart}-${isPositive ? "pos" : "neg"}`;
  };

  const generateDescription = (age, deceased, active, gender, address, isPositive) => {
    const state = address === "HI" ? "HI" : address === "VI" ? "VI" : "nowhere";
    return `${age} ${deceased === null || deceased === false ? "living" : "deceased"} ${
      active ? "active" : "inactive"
    } ${gender} from ${state} ${isPositive ? "HIV positive" : "HIV negative"}`;
  };

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
          display: "Asymptomatic human immunodeficiency virus [HIV] infection status",
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

  const testCases = [];

  variables.deceased.forEach((deceased) => {
    variables.active.forEach((active) => {
      variables.gender.forEach((gender) => {
        variables.age.forEach((age) => {
          variables.address.forEach((address) => {
            // Negative case
            const negId = generateId(deceased, active, gender, age, address, false);
            const negDescription = generateDescription(age, deceased, active, gender, address);
            const negRequiresAction = isActionRequired(deceased, active, age, false);
            const negBirthDate = calculateBirthDate(age);

            testCases.push({
              id: negId,
              isPositive: false,
              patient: {
                resourceType: "Patient",
                id: `hiv-${negId}`,
                extension: [
                  {
                    url: "http://hl7.org/fhir/StructureDefinition/patient-comment",
                    valueString: negDescription,
                  },
                  {
                    url: "http://cds.hopena.info/StructureDefinition/patient-requires-action",
                    valueString: negRequiresAction.toString(),
                  },
                ],
                identifier: [
                  {
                    system: "http://example.org/hiv-screening",
                    value: negId,
                  },
                ],
                name: [
                  {
                    given: ["Absolutely"],
                    family: "Nobody",
                  },
                ],
                birthDate: negBirthDate,
                gender: gender,
                active: active,
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
              },
            });

            // Positive case
            const posId = generateId(deceased, active, gender, age, address, true);
            const posDescription = generateDescription(age, deceased, active, gender, address);
            const posRequiresAction = isActionRequired(deceased, active, age, true);
            const posBirthDate = calculateBirthDate(age);

            testCases.push({
              id: posId,
              isPositive: true,
              patient: {
                resourceType: "Patient",
                id: `hiv-${posId}`,
                extension: [
                  {
                    url: "http://hl7.org/fhir/StructureDefinition/patient-comment",
                    valueString: posDescription,
                  },
                  {
                    url: "http://cds.hopena.info/StructureDefinition/patient-requires-action",
                    valueString: posRequiresAction.toString(),
                  },
                ],
                identifier: [
                  {
                    system: "http://example.org/hiv-screening",
                    value: posId,
                  },
                ],
                name: [
                  {
                    given: ["Absolutely"],
                    family: "Nobody",
                  },
                ],
                birthDate: posBirthDate,
                gender: gender,
                active: active,
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
              },
              condition: generateConditionResource(posId),
            });
          });
        });
      });
    });
  });

  return testCases;
};

const saveTestCases = (testCases) => {
  testCases.forEach(({ id, isPositive, patient, condition }) => {
    const patientDir = path.join(
      "input",
      "test",
      "PlanDefinition",
      "HIVScreening",
      `hiv-${id}`,
      "Patient"
    );
    fs.mkdirSync(patientDir, { recursive: true });
    fs.writeFileSync(path.join(patientDir, `hiv-${id}.json`), JSON.stringify(patient, null, 2));

    if (isPositive) {
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
  });

  console.log(`Saved ${testCases.length} test cases to individual directories.`);
};

// Generate and save test cases
const testCases = generateTestCases();
saveTestCases(testCases);