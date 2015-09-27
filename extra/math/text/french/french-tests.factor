USING: math math.functions math.parser math.text.french sequences tools.test ;

{ "zéro" } [ 0 number>text ] unit-test
{ "vingt et un" } [ 21 number>text ] unit-test
{ "vingt-deux" } [ 22 number>text ] unit-test
{ "deux mille" } [ 2000 number>text ] unit-test
{ "soixante et un" } [ 61 number>text ] unit-test
{ "soixante-deux" } [ 62 number>text ] unit-test
{ "quatre-vingts" } [ 80 number>text ] unit-test
{ "quatre-vingt-un" } [ 81 number>text ] unit-test
{ "quatre-vingt-onze" } [ 91 number>text ] unit-test
{ "deux cents" } [ 200 number>text ] unit-test
{ "mille deux cents" } [ 1200 number>text ] unit-test
{ "mille deux cent quatre-vingts" } [ 1280 number>text ] unit-test
{ "mille deux cent quatre-vingt-un" } [ 1281 number>text ] unit-test
{ "un billion deux cent vingt milliards quatre-vingts millions trois cent quatre-vingt mille deux cents" } [ 1220080380200 number>text ] unit-test
{ "un million" } [ 1000000 number>text ] unit-test
{ "un million un" } [ 1000001 number>text ] unit-test
{ "moins vingt" } [ -20 number>text ] unit-test
{ 104 } [ -1 10 102 ^ - number>text length ] unit-test
! Check that we do not exhaust stack
{ 1484 } [ 10 100 ^ 1 - number>text length ] unit-test
