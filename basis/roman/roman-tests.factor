USING: roman tools.test ;

{ "i" } [ 1 >roman ] unit-test
{ "ii" } [ 2 >roman ] unit-test
{ "iii" } [ 3 >roman ] unit-test
{ "iv" } [ 4 >roman ] unit-test
{ "v" } [ 5 >roman ] unit-test
{ "vi" } [ 6 >roman ] unit-test
{ "vii" } [ 7 >roman ] unit-test
{ "viii" } [ 8 >roman ] unit-test
{ "ix" } [ 9 >roman ] unit-test
{ "x" } [ 10 >roman ] unit-test
{ "mdclxvi" } [ 1666 >roman ] unit-test
{ "mmmcdxliv" } [ 3444 >roman ] unit-test
{ "mmmcmxcix" } [ 3999 >roman ] unit-test
{ "MMMCMXCIX" } [ 3999 >ROMAN ] unit-test
{ 3999 } [ 3999 >ROMAN roman> ] unit-test
{ 1 } [ 1 >roman roman> ] unit-test
{ 2 } [ 2 >roman roman> ] unit-test
{ 3 } [ 3 >roman roman> ] unit-test
{ 4 } [ 4 >roman roman> ] unit-test
{ 5 } [ 5 >roman roman> ] unit-test
{ 6 } [ 6 >roman roman> ] unit-test
{ 7 } [ 7 >roman roman> ] unit-test
{ 8 } [ 8 >roman roman> ] unit-test
{ 9 } [ 9 >roman roman> ] unit-test
{ 10 } [ 10 >roman roman> ] unit-test
{ 1666 } [ 1666 >roman roman> ] unit-test
{ 3444 } [ 3444 >roman roman> ] unit-test
{ 3999 } [ 3999 >roman roman> ] unit-test
[ 0 >roman ] must-fail
[ 40000 >roman ] must-fail
{ "vi" } [ "iii" "iii"  roman+ ] unit-test
{ "viii" } [ "x" "ii"  roman- ] unit-test
{ "ix" } [ "iii" "iii"  roman* ] unit-test
{ "i" } [ "iii" "ii" roman/i ] unit-test
{ "i" "ii" } [ "v" "iii"  roman/mod ] unit-test
[ "iii" "iii"  roman- ] must-fail

{ 30 } [ ROMAN: xxx ] unit-test

[ roman+ ] must-infer
[ roman- ] must-infer
[ roman* ] must-infer
[ roman/i ] must-infer
[ roman/mod ] must-infer
