IN: tr.tests
USING: tr tools.test ascii ;

TR: tr-test ch>upper "ABC" "XYZ" ;

{ "XXYY" } [ "aabb" tr-test ] unit-test
{ "XXYY" } [ "AABB" tr-test ] unit-test
{ "XXYYZZ" } [ "AABBCC" tr-test ] unit-test
{ { 12345 } } [ { 12345 } tr-test ] unit-test

TR: tr-test-mismatch "ab" "z" ;
{ "zzbb" } [ "aabb" tr-test-mismatch ] unit-test
