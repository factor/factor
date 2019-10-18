USING: tools.test base64 ;

[ "abcdefghijklmnopqrstuvwxyz" ] [ "abcdefghijklmnopqrstuvwxyz" >base64 base64>
] unit-test
[ "" ] [ "" >base64 base64> ] unit-test
[ "a" ] [ "a" >base64 base64> ] unit-test
[ "ab" ] [ "ab" >base64 base64> ] unit-test
[ "abc" ] [ "abc" >base64 base64> ] unit-test
