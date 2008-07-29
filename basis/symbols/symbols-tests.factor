USING: kernel symbols tools.test parser generic words accessors ;
IN: symbols.tests

[ ] [ SYMBOLS: a b c ; ] unit-test
[ a ] [ a ] unit-test
[ b ] [ b ] unit-test
[ c ] [ c ] unit-test

DEFER: blah

[ ] [ "IN: symbols.tests GENERIC: blah" eval ] unit-test
[ ] [ "IN: symbols.tests USE: symbols SYMBOLS: blah ;" eval ] unit-test

[ f ] [ \ blah generic? ] unit-test
[ t ] [ \ blah symbol? ] unit-test

[ "IN: symbols.tests USE: symbols SINGLETONS: blah blah blah ;" eval ]
[ error>> error>> def>> \ blah eq? ]
must-fail-with

