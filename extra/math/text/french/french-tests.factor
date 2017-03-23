USING: math math.functions math.parser math.text.french sequences tools.test ;

{ "zéro" } [ 0 number>text ] unit-test
{ "vingt-et-un" } [ 21 number>text ] unit-test
{ "vingt-deux" } [ 22 number>text ] unit-test
{ "deux-mille" } [ 2000 number>text ] unit-test
{ "soixante-et-un" } [ 61 number>text ] unit-test
{ "soixante-deux" } [ 62 number>text ] unit-test
{ "quatre-vingts" } [ 80 number>text ] unit-test
{ "quatre-vingt-un" } [ 81 number>text ] unit-test
{ "quatre-vingt-onze" } [ 91 number>text ] unit-test
{ "deux-cents" } [ 200 number>text ] unit-test
{ "mille-deux-cents" } [ 1200 number>text ] unit-test
{ "mille-deux-cent-quatre-vingts" } [ 1280 number>text ] unit-test
{ "mille-deux-cent-quatre-vingt-un" } [ 1281 number>text ] unit-test
{ "un billion deux-cent-vingt milliards quatre-vingts millions trois-cent-quatre-vingt-mille-deux-cents" } [ 1220080380200 number>text ] unit-test
{ "un million" } [ 1000000 number>text ] unit-test
{ "un million un" } [ 1000001 number>text ] unit-test
{ "moins vingt" } [ -20 number>text ] unit-test
{ 104 } [ -1 10 102 ^ - number>text length ] unit-test
! Check that we do not exhaust stack
{ 1484 } [ 10 100 ^ 1 - number>text length ] unit-test
{ "un demi" } [ 1/2 number>text ] unit-test
{ "trois demis" } [ 3/2 number>text ] unit-test
{ "un tiers" } [ 1/3 number>text ] unit-test
{ "deux tiers" } [ 2/3 number>text ] unit-test
{ "un quart" } [ 1/4 number>text ] unit-test
{ "un cinquième" } [ 1/5 number>text ] unit-test
{ "un seizième" } [ 1/16 number>text ] unit-test
{ "mille cent-vingt-septièmes" } [ 1000/127 number>text ] unit-test
{ "mille-cent vingt-septièmes" } [ 1100/27 number>text ] unit-test
{ "mille-cent-dix-neuf septièmes" } [ 1119/7 number>text ] unit-test
{ "moins un quatre-vingtième" } [ -1/80 number>text ] unit-test
{ "moins dix-neuf quatre-vingtièmes" } [ -19/80 number>text ] unit-test
