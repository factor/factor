USING: base91 byte-arrays kernel sequences tools.test ;

{ t } [ 256 <iota> >byte-array dup >base91 base91> = ] unit-test

{ B{ } } [ f >base91 ] unit-test
{ "AA" } [ B{ 0 } >base91 "" like ] unit-test
{ "GB" } [ "a" >base91 "" like ] unit-test
{ "#GD" } [ "ab" >base91 "" like ] unit-test
{ "#G(I" } [ "abc" >base91 "" like ] unit-test
{ "#G(IZ" } [ "abcd" >base91 "" like ] unit-test
{ "#G(Ic,A" } [ "abcde" >base91 "" like ] unit-test
{ "#G(Ic,WC" } [ "abcdef" >base91 "" like ] unit-test
{ "#G(Ic,5pG" } [ "abcdefg" >base91 "" like ] unit-test

{ B{ } } [ f base91> ] unit-test
{ "\0" } [ "AA" base91> "" like ] unit-test
{ "a" } [ "GB" base91> "" like ] unit-test
{ "ab" } [ "#GD" base91> "" like ] unit-test
{ "abc" } [ "#G(I" base91> "" like ] unit-test
{ "abcd" } [ "#G(IZ" base91> "" like ] unit-test
{ "abcde" } [ "#G(Ic,A" base91> "" like ] unit-test
{ "abcdef" } [ "#G(Ic,WC" base91> "" like ] unit-test
{ "abcdefg" } [ "#G(Ic,5pG" base91> "" like ] unit-test
