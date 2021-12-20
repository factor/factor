USING: accessors classes.tuple.parser lexer words classes
sequences math kernel slots tools.test parser compiler.units
arrays classes.tuple eval multiline splitting ;
IN: classes.tuple.parser.tests

TUPLE: test-1 ;

{ t } [ test-1 "slots" word-prop empty? ] unit-test

TUPLE: test-2 < test-1 ;

{ t } [ test-2 "slots" word-prop empty? ] unit-test
{ test-1 } [ test-2 superclass-of ] unit-test

TUPLE: test-3 a ;

{ { "a" } } [ test-3 "slots" word-prop [ name>> ] map ] unit-test

{ object } [ "a" test-3 "slots" word-prop slot-named class>> ] unit-test

TUPLE: test-4 < test-3 b ;

{ { "b" } } [ test-4 "slots" word-prop [ name>> ] map ] unit-test

TUPLE: test-5 { a integer } ;

{ { { "a" integer } } }
[
    test-5 "slots" word-prop
    [ [ name>> ] [ class>> ] bi 2array ] map
] unit-test

TUPLE: test-6 < test-5 { b integer } ;

{ integer } [ "b" test-6 "slots" word-prop slot-named class>> ] unit-test

{ { { "b" integer } } }
[
    test-6 "slots" word-prop
    [ [ name>> ] [ class>> ] bi 2array ] map
] unit-test

TUPLE: test-7 { b integer initial: 3 } ;

{ 3 } [ "b" test-7 "slots" word-prop slot-named initial>> ] unit-test

TUPLE: test-8 { b integer read-only } ;

{ t } [ "b" test-8 "slots" word-prop slot-named read-only>> ] unit-test

DEFER: foo

[ "IN: classes.tuple.parser.tests TUPLE: foo < test-1 < ;" eval( -- ) ]
[ error>> invalid-slot-name? ]
must-fail-with

[ "IN: classes.tuple.parser.tests TUPLE: foo :" eval( -- ) ]
[ error>> invalid-slot-name? ]
must-fail-with

[ "IN: classes.tuple.parser.tests TUPLE: foo" eval( -- ) ]
[ error>> unexpected-eof? ]
must-fail-with

2 [
    [ "IN: classes.tuple.parser.tests USE: alien TUPLE: foo { slot dll } ;" eval( -- ) ]
    [ error>> bad-initial-value? ]
    must-fail-with

    [ f ] [ \ foo tuple-class? ] unit-test
] times

2 [
    [ "IN: classes.tuple.parser.tests USE: arrays TUPLE: foo { slot array initial: 5 } ;" eval( -- ) ]
    [ error>> bad-initial-value? ]
    must-fail-with

    [ f ] [ \ foo tuple-class? ] unit-test
] times

[ "IN: classes.tuple.parser.tests USE: arrays TUPLE: foo slot { slot array } ;" eval( -- ) ]
[ error>> duplicate-slot-names? ]
must-fail-with

{ f } [ \ foo tuple-class? ] unit-test

{ } [
    [
        { test-1 test-2 test-3 test-4 test-5 test-6 test-7 test-8 foo }
        [ dup class? [ forget-class ] [ drop ] if ] each
    ] with-compilation-unit
] unit-test

TUPLE: syntax-test bar baz ;

{ T{ syntax-test } } [ T{ syntax-test } ] unit-test
{ T{ syntax-test f { 2 3 } { 4 { 5 } } } }
[ T{ syntax-test { bar { 2 3 } } { baz { 4 { 5 } } } } ] unit-test

! Corner case
TUPLE: parsing-corner-case x ;

{ T{ parsing-corner-case f 3 } } [
    {
        "USE: classes.tuple.parser.tests"
        "T{ parsing-corner-case"
        "    f"
        "    3"
        "}"
    } join-lines eval( -- tuple )
] unit-test

{ T{ parsing-corner-case f 3 } } [
    {
        "USE: classes.tuple.parser.tests"
        "T{ parsing-corner-case"
        "    { x 3 }"
        "}"
    } join-lines eval( -- tuple )
] unit-test

{ T{ parsing-corner-case f 3 } } [
    {
        "USE: classes.tuple.parser.tests"
        "T{ parsing-corner-case {"
        "    x 3 }"
        "}"
    } join-lines eval( -- tuple )
] unit-test


[
    {
        "USE: classes.tuple.parser.tests T{ parsing-corner-case"
        "    { x 3 }"
    } join-lines eval( -- tuple )
] [ error>> unexpected-eof? ] must-fail-with

[
    {
        "USE: classes.tuple.parser.tests T{ parsing-corner-case {"
        "    x 3 }"
    } join-lines eval( -- tuple )
] [ error>> unexpected-eof? ] must-fail-with

TUPLE: bad-inheritance-tuple ;
[
    "IN: classes.tuple.parser.tests TUPLE: bad-inheritance-tuple < bad-inheritance-tuple ;" eval( -- )
] [ error>> bad-inheritance? ] must-fail-with

TUPLE: bad-inheritance-tuple2 ;
TUPLE: bad-inheritance-tuple3 < bad-inheritance-tuple2 ;
[
    "IN: classes.tuple.parser.tests TUPLE: bad-inheritance-tuple2 < bad-inheritance-tuple3 ;" eval( -- )
] [ error>> bad-inheritance? ] must-fail-with

! This must not fail
TUPLE: tup ;
UNION: u tup ;

{ } [ "IN: classes.tuple.parser.tests TUPLE: u < tup ;" eval( -- ) ] unit-test

{ t } [ u new tup? ] unit-test
