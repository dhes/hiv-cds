const fs = require('fs');

const generateTestCases = () => {
  const variables = {
    deceased: [null, true, false, "2023-01-01"],
    active: [true, false],
    gender: ["male", "female"],
    age: ["too-young", "just-old-enough", "just-young-enough", "too-old"],
    address: [null, "HI", "VI"],
  };

  const referenceDate = "2024-01-01";

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

  const generateDescription = (age, gender, address) => {
    const state = address === "HI" ? "HI" : address === "VI" ? "VI" : "nowhere";
    return `${age} ${gender} from ${state}`;
  };

  const testCases = [];

  variables.deceased.forEach((deceased) => {
    variables.active.forEach((active) => {
      variables.gender.forEach((gender) => {
        variables.age.forEach((age) => {
          variables.address.forEach((address) => {
            const id = generateId(deceased, active, gender, age, address);
            const description = generateDescription(age, gender, address);
            const requiresAction = isActionRequired(deceased, active, age);
            const birthDate = (() => {
              if (age === "too-young") return "2010-01-02";
              if (age === "just-old-enough") return "2010-01-01";
              if (age === "just-young-enough") return "1959-01-01";
              if (age === "too-old") return "1958-12-31";
            })();

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

            testCases.push(resource);
          });
        });
      });
    });
  });

  return testCases;
};

// Generate test cases and save to a file
const testCases = generateTestCases();
fs.writeFileSync("hiv_test_cases.json", JSON.stringify(testCases, null, 2));

console.log("HIV test cases generated and saved to hiv_test_cases.json");