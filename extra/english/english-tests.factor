USE: tools.test
IN: english

{ "record" } [ "records" singularize ] unit-test
{ "FOOT" } [ "FEET" singularize ] unit-test

{ "friends" } [ "friend" pluralize ] unit-test
{ "enemies" } [ "enemy" pluralize ] unit-test
{ "Sheep" } [ "Sheep" pluralize ] unit-test

{ "a10n" } [ "abbreviation" a10n ] unit-test
{ "i18n" } [ "internationalization" a10n ] unit-test

{ "3 babies" } [ 3 "baby" count-of-things ] unit-test
{ "1 pipe" } [ 1 "pipe" count-of-things ] unit-test
{ "0 pipes" } [ 0 "pipe" count-of-things ] unit-test
