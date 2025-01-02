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

  const isActionRequired = (deceased, active, age) => {
    if (deceased || !active || age === "too-young" || age === "too-old") {
      return false;
    }
    return true;
  };

  const generateId = (deceased, active, gender, age, address) => {
    const deceasedPart = deceased === null ? "f" : deceased === true ? "t" : deceased === false ? "f" : "d";
    const addressPart = address === null ? "none" : address;
    return `${deceasedPart}-${active ? "t" : "f"}-${gender[0]}-${age}-${addressPart}`;
  };

  const generateDescription = (age, deceased, active, gender, address) => {
    const state = address === "HI" ? "HI" : address === "VI" ? "VI" : "nowhere";
    return `${age} ${deceased === null ? "living" : deceased === true ? "deceased" : deceased === false ? "living" : "deceased"} ${active ? "active" : "inactive"} ${gender} from ${state}`;
  };

  const testCases = [];

  variables.deceased.forEach((deceased) => {
    variables.active.forEach((active) => {
      variables.gender.forEach((gender) => {
        variables.age.forEach((age) => {
          variables.address.forEach((address) => {
            const id = generateId(deceased, active, gender, age, address);
            const description = generateDescription(age, deceased, active, gender, address);
            const requiresAction = isActionRequired(deceased, active, age);
            const birthDate = calculateBirthDate(age);

            const deceasedElement = (() => {
              if (deceased === true) return { deceasedBoolean: true };
              if (deceased === false) return { deceasedBoolean: false };
              if (typeof deceased === "string") return { deceasedDateTime: deceased };
              return {};
            })();

            const resource = {
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
              birthDate: birthDate,
              gender: gender,
              active: active,
              ...deceasedElement,
              ...(address && {
                address: [
                  {
                    use: "home",
                    state: address,
                  },
                ],
              }),
            };

            testCases.push({ id, resource });
          });
        });
      });
    });
  });

  return testCases;
};

const saveTestCases = (testCases) => {
  testCases.forEach(({ id, resource }) => {
    const dirPath = path.join(
      "input",
      "test",
      "PlanDefinition",
      "HIVScreening",
      `hiv-${id}`,
      "Patient"
    );
    fs.mkdirSync(dirPath, { recursive: true });
    const filePath = path.join(dirPath, `hiv${id}.json`);
    fs.writeFileSync(filePath, JSON.stringify(resource, null, 2));
  });
  console.log(`Saved ${testCases.length} test cases to individual directories.`);
};

// Generate test cases and save them
const testCases = generateTestCases();
saveTestCases(testCases);