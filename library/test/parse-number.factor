IN: scratchpad
USE: math
USE: parser
USE: strings
USE: test
USE: unparser

[ f ]
[ f ]
[ dec> ]
test-word

[ f ]
[ "12345abcdef" ]
[ dec> ]
test-word

[ t ]
[ "-12" ]
[ dec> 0 < ]
test-word

[ f ]
[ "--12" ]
[ dec> ]
test-word

[ f ]
[ "-" ]
[ dec> ]
test-word

[ f ]
[ "e" ]
[ dec> ]
test-word

[ "100.0" ]
[ "1.0e2" ]
[ dec> unparse ]
test-word

[ "-100.0" ]
[ "-1.0e2" ]
[ dec> unparse ]
test-word

[ "0.01" ]
[ "1.0e-2" ]
[ dec> unparse ]
test-word

[ "-0.01" ]
[ "-1.0e-2" ]
[ dec> unparse ]
test-word

[ f ]
[ "-1e-2e4" ]
[ dec> ]
test-word

[ "3.14" ]
[ "3.14" ]
[ dec> unparse ]
test-word

[ f ]
[ "." ]
[ dec> ]
test-word

[ f ]
[ ".e" ]
[ dec> ]
test-word

[ "101.0" ]
[ "1.01e2" ]
[ dec> unparse ]
test-word

[ "-101.0" ]
[ "-1.01e2" ]
[ dec> unparse ]
test-word

[ "1.01" ]
[ "101.0e-2" ]
[ dec> unparse ]
test-word

[ "-1.01" ]
[ "-101.0e-2" ]
[ dec> unparse ]
test-word

[ 5 ]
[ "10/2" ]
[ dec> ]
test-word

[ -5 ]
[ "-10/2" ]
[ dec> ]
test-word

[ -5 ]
[ "10/-2" ]
[ dec> ]
test-word

[ 5 ]
[ "-10/-2" ]
[ dec> ]
test-word

[ f ]
[ "10.0/2" ]
[ dec> ]
test-word

[ f ]
[ "1e1/2" ]
[ dec> ]
test-word

[ f ]
[ "e/2" ]
[ dec> ]
test-word

[ "33/100" ]
[ "66/200" ]
[ dec> unparse ]
test-word
