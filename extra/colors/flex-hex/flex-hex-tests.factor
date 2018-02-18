USING: colors.flex-hex tools.test ;

{ "00b000" } [ "#zqbttv" flex-hex ] unit-test

{ "0f0000" } [ "f" flex-hex ] unit-test
{ "000f00" } [ "0f" flex-hex ] unit-test
{ "000f00" } [ "0f0" flex-hex ] unit-test
{ "0f0f00" } [ "0f0f" flex-hex ] unit-test
{ "0ff000" } [ "0f0f0f0" flex-hex ] unit-test

{ "ad0e0e" } [ "adamlevine" flex-hex ] unit-test
{ "000000" } [ "MrT" flex-hex ] unit-test
{ "00c000" } [ "sick" flex-hex ] unit-test
{ "c0a000" } [ "crap" flex-hex ] unit-test
{ "c00000" } [ "chucknorris" flex-hex ] unit-test

{ "6ecde0" } [
    "6db6ec49efd278cd0bc92d1e5e072d68" flex-hex
] unit-test
