USING: http tools.test ;
IN: temporary

[ "hello%20world" ] [ "hello world" url-encode ] unit-test
[ "hello world" ] [ "hello%20world" url-decode ] unit-test
[ "~hello world" ] [ "%7ehello+world" url-decode ] unit-test
[ "" ] [ "%XX%XX%XX" url-decode ] unit-test
[ "" ] [ "%XX%XX%X" url-decode ] unit-test

[ "hello world"   ] [ "hello+world"    url-decode ] unit-test
[ "hello world"   ] [ "hello%20world"  url-decode ] unit-test
[ " ! "           ] [ "%20%21%20"      url-decode ] unit-test
[ "hello world"   ] [ "hello world%"   url-decode ] unit-test
[ "hello world"   ] [ "hello world%x"  url-decode ] unit-test
[ "hello%20world" ] [ "hello world"    url-encode ] unit-test
[ "%20%21%20"     ] [ " ! "            url-encode ] unit-test
