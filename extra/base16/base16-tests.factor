USING: base16 byte-arrays kernel sequences strings tools.test ;

{ t } [ 256 <iota> >byte-array dup >base16 base16> = ] unit-test

{ "00" } [ B{ 0 } >base16 "" like ] unit-test
{ "01" } [ B{ 1 } >base16 "" like ] unit-test
{ "0102" } [ B{ 1 2 } >base16 "" like ] unit-test

{ B{ 0 } } [ "00" base16> ] unit-test
{ B{ 1 } } [ "01" base16> ] unit-test
{ B{ 1 2 } } [ "0102" base16> ] unit-test

[ "0" base16> ] [ malformed-base16? ] must-fail-with
[ "Z" base16> ] [ malformed-base16? ] must-fail-with

{ "" } [ "" >base16 >string ] unit-test
{ "66" } [ "f" >base16 >string ] unit-test
{ "666F" } [ "fo" >base16 >string ] unit-test
{ "666F6F" } [ "foo" >base16 >string ] unit-test
{ "666F6F62" } [ "foob" >base16 >string ] unit-test
{ "666F6F6261" } [ "fooba" >base16 >string ] unit-test
{ "666F6F626172" } [ "foobar" >base16 >string ] unit-test

{ "" } [ "" base16> >string ] unit-test
{ "f" } [ "66" base16> >string ] unit-test
{ "fo" } [ "666F" base16> >string ] unit-test
{ "foo" } [ "666F6F" base16> >string ] unit-test
{ "foob" } [ "666F6F62" base16> >string ] unit-test
{ "fooba" } [ "666F6F6261" base16> >string ] unit-test
{ "foobar" } [ "666F6F626172" base16> >string ] unit-test
