IN: scratchpad
USE: arithmetic
USE: parser
USE: stdio
USE: strings
USE: test

"Parse number tests" print

[ f ]
[ f ]
[ parse-number ]
test-word

[ f ]
[ "12345abcdef" ]
[ parse-number ]
test-word

[ t ]
[ "-12" ]
[ parse-number 0 < ]
test-word

[ f ]
[ "--12" ]
[ parse-number ]
test-word

[ f ]
[ "-" ]
[ parse-number ]
test-word

[ f ]
[ "e" ]
[ parse-number ]
test-word

[ "100.0" ]
[ "1e2" ]
[ parse-number >str ]
test-word

[ "-100.0" ]
[ "-1e2" ]
[ parse-number >str ]
test-word

[ "0.01" ]
[ "1e-2" ]
[ parse-number >str ]
test-word

[ "-0.01" ]
[ "-1e-2" ]
[ parse-number >str ]
test-word

[ f ]
[ "-1e-2e4" ]
[ parse-number ]
test-word

[ "3.14" ]
[ "3.14" ]
[ parse-number >str ]
test-word

[ f ]
[ "." ]
[ parse-number ]
test-word

[ f ]
[ ".e" ]
[ parse-number ]
test-word

[ "101.0" ]
[ "1.01e2" ]
[ parse-number >str ]
test-word

[ "-101.0" ]
[ "-1.01e2" ]
[ parse-number >str ]
test-word

[ "1.01" ]
[ "101e-2" ]
[ parse-number >str ]
test-word

[ "-1.01" ]
[ "-101e-2" ]
[ parse-number >str ]
test-word

[ "123456789123456789123456789" ]
[ "123456789123456789123456789" ]
[ parse-number >str ]
test-word

[ 5 ]
[ "10/2" ]
[ parse-number ]
test-word

[ -5 ]
[ "-10/2" ]
[ parse-number ]
test-word

[ f ]
[ "10/-2" ]
[ parse-number ]
test-word

[ f ]
[ "-10/-2" ]
[ parse-number ]
test-word

[ f ]
[ "10.0/2" ]
[ parse-number ]
test-word

[ f ]
[ "1e1/2" ]
[ parse-number ]
test-word

[ f ]
[ "e/2" ]
[ parse-number ]
test-word

[ "33/100" ]
[ "66/200" ]
[ parse-number >str ]
test-word

"Parse number tests done" print
