USING: base92 byte-arrays kernel sequences tools.test ;

{ t } [ 256 <iota> >byte-array dup >base92 base92> = ] unit-test

{ "Fc_$aOTdKnsM*k" } [ "hello world" >base92 "" like ] unit-test
{ "hello world" } [ "Fc_$aOTdKnsM*k" base92> "" like ] unit-test

{ "~" } [ f >base92 "" like ] unit-test
{ "!!" } [ B{ 0 } >base92 "" like ] unit-test
{ "D," } [ "a" >base92 "" like ] unit-test
{ "D82" } [ "ab" >base92 "" like ] unit-test
{ "D8<q" } [ "abc" >base92 "" like ] unit-test
{ "D8<rF" } [ "abcd" >base92 "" like ] unit-test
{ "D8<rU3B" } [ "abcde" >base92 "" like ] unit-test
{ "D8<rU3ay" } [ "abcdef" >base92 "" like ] unit-test
{ "D8<rU3b#>" } [ "abcdefg" >base92 "" like ] unit-test

{ B{ } } [ f base92> ] unit-test
{ "\0" } [ "!!" base92> "" like ] unit-test
{ "a" } [ "D," base92> "" like ] unit-test
{ "ab" } [ "D82" base92> "" like ] unit-test
{ "abc" } [ "D8<q" base92> "" like ] unit-test
{ "abcd" } [ "D8<rF" base92> "" like ] unit-test
{ "abcde" } [ "D8<rU3B" base92> "" like ] unit-test
{ "abcdef" } [ "D8<rU3ay" base92> "" like ] unit-test
{ "abcdefg" } [ "D8<rU3b#>" base92> "" like ] unit-test
