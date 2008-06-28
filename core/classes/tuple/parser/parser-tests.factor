IN: classes.tuple.parser.tests
USING: accessors classes.tuple.parser lexer words classes
sequences math kernel slots tools.test parser compiler.units ;

TUPLE: test-1 ;

[ t ] [ test-1 "slot-names" word-prop empty? ] unit-test

TUPLE: test-2 < test-1 ;

[ t ] [ test-2 "slot-names" word-prop empty? ] unit-test
[ test-1 ] [ test-2 superclass ] unit-test

TUPLE: test-3 a ;

[ { "a" } ] [ test-3 "slot-names" word-prop ] unit-test

[ object ] [ "a" test-3 "slots" word-prop slot-named class>> ] unit-test

TUPLE: test-4 < test-3 b ;

[ { "b" } ] [ test-4 "slot-names" word-prop ] unit-test

TUPLE: test-5 { "a" integer } ;

[ { { "a" integer } } ] [ test-5 "slot-names" word-prop ] unit-test

TUPLE: test-6 < test-5 { "b" integer } ;

[ integer ] [ "b" test-6 "slots" word-prop slot-named class>> ] unit-test

[ { { "b" integer } } ] [ test-6 "slot-names" word-prop ] unit-test

TUPLE: test-7 { "b" integer initial: 3 } ;

[ 3 ] [ "b" test-7 "slots" word-prop slot-named initial>> ] unit-test

TUPLE: test-8 { "b" integer read-only: t } ;

[ t ] [ "b" test-8 "slots" word-prop slot-named read-only>> ] unit-test

[ "IN: classes.tuple.parser.tests TUPLE: foo < test-1 < ;" eval ]
[ error>> invalid-slot-name? ]
must-fail-with

[ "IN: classes.tuple.parser.tests TUPLE: foo :" eval ]
[ error>> invalid-slot-name? ]
must-fail-with

[ "IN: classes.tuple.parser.tests TUPLE: foo" eval ]
[ error>> unexpected-eof? ]
must-fail-with

[ ] [
    [
        { test-1 test-2 test-3 test-4 test-5 test-6 test-7 test-8 }
        [ dup class? [ forget-class ] [ drop ] if ] each
    ] with-compilation-unit
] unit-test
