IN: scratchpad
USE: format
USE: test

[ "123" ] [ "123" 2 decimal-places ] unit-test
[ "123.12" ] [ "123.12" 2 decimal-places ] unit-test
[ "123.123" ] [ "123.123" 5 decimal-places ] unit-test
[ "123" ] [ "123.123" 0 decimal-places ] unit-test
[ "05" ] [ "5" 2 digits ] unit-test
[ "666" ] [ "666" 2 digits ] unit-test
