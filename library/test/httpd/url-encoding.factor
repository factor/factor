IN: scratchpad
USE: url-encoding
USE: test

[ "hello%20world" ] [ "hello world" url-encode ] unit-test
[ "hello world" ] [ "hello%20world" url-decode ] unit-test
[ "~hello world" ] [ "%7ehello+world" url-decode ] unit-test
[ "" ] [ "%XX%XX%XX" url-decode ] unit-test
[ "" ] [ "%XX%XX%X" url-decode ] unit-test
