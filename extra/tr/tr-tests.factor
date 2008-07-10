IN: tr.tests
USING: tr tools.test unicode.case ;

TR: tr-test ch>upper "ABC" "XYZ" ;

[ "XXYY" ] [ "aabb" tr-test ] unit-test
[ "XXYY" ] [ "AABB" tr-test ] unit-test
