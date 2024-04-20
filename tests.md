Principle of simplicity
- Example - The simplest way to record pregnancy is by a positive pregnancy test because it requires no work on the part of the user. 
Principle of common practice
- Most practices have a problem list but some my not maintain it diligently. Therefore it is reasonable to record pregnancy as an entry in the problem list, but it might be a mistake to assume that it will be removed from the problem list in a timely manner. 

|domain|boundary|
|---|---|
|age|age>=13 and <=64|
|age|tested while in age range?|

Tested in this table alway means `tested while age in [13,64]`

|stub|domain|description|action?|text fragment|
|---|---|---|---|---|
|hiv-too-young|age|under age 13|false|null|
|hiv-just-old-enough|age|age 13 on reference date, not tested|true|never having been tested|
|hiv-just-young-enough|age|turns 65 in 1 day, not tested|true|never having been tested|
|hiv-too-old|age|over age 64|false|null|
|hiv-medium-age|age|40 years old, tested|false|null|
|hiv-pregnant-old-test|pregnancy|a pregnant person whose HIV test precedes the positive pregnancy test|true|pregnancy event|
|hiv-pregnant|pregnancy|a pregnant person with no HIV test|true|pregnancy event|

