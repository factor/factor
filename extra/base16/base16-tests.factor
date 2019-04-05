USING: base16 byte-arrays kernel sequences tools.test ;

{ t } [ 256 <iota> >byte-array dup >base16 base16> = ] unit-test

{ "00" } [ B{ 0 } >base16 "" like ] unit-test
{ "01" } [ B{ 1 } >base16 "" like ] unit-test
{ "0102" } [ B{ 1 2 } >base16 "" like ] unit-test

{ B{ 0 } } [ "00" base16> ] unit-test
{ B{ 1 } } [ "01" base16> ] unit-test
{ B{ 1 2 } } [ "0102" base16> ] unit-test

[ "0" base16> ] [ malformed-base16? ] must-fail-with
[ "Z" base16> ] [ malformed-base16? ] must-fail-with
