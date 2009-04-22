USING: alien arrays definitions generic assocs hashtables io
kernel math namespaces parser prettyprint sequences strings
tools.test vectors words quotations classes
classes.private classes.union classes.mixin classes.predicate
classes.algebra vectors definitions source-files
compiler.units kernel.private sorting vocabs eval ;
IN: classes.mixin.tests

! Test mixins
MIXIN: sequence-mixin

INSTANCE: array sequence-mixin
INSTANCE: vector sequence-mixin
INSTANCE: slice sequence-mixin

MIXIN: assoc-mixin

INSTANCE: hashtable assoc-mixin

GENERIC: collection-size ( x -- y )

M: sequence-mixin collection-size length ;

M: assoc-mixin collection-size assoc-size ;

[ t ] [ array sequence-mixin class<= ] unit-test
[ t ] [ { 1 2 3 } sequence-mixin? ] unit-test
[ 3 ] [ { 1 2 3 } collection-size ] unit-test
[ f ] [ H{ { 1 2 } { 2 3 } } sequence-mixin? ] unit-test
[ t ] [ H{ { 1 2 } { 2 3 } } assoc-mixin? ] unit-test
[ 2 ] [ H{ { 1 2 } { 2 3 } } collection-size ] unit-test

! Test mixing in of new classes after the fact
DEFER: mx1
FORGET: mx1

MIXIN: mx1

INSTANCE: integer mx1

[ t ] [ integer mx1 class<= ] unit-test
[ t ] [ mx1 integer class<= ] unit-test
[ t ] [ mx1 number class<= ] unit-test

"IN: classes.mixin.tests USE: arrays INSTANCE: array mx1" eval( -- )

[ t ] [ array mx1 class<= ] unit-test
[ f ] [ mx1 number class<= ] unit-test

[ \ mx1 forget ] with-compilation-unit

USE: io.streams.string

2 [
    [ "mixin-forget-test" forget-source ] with-compilation-unit
    
    [ ] [
        {
            "USING: sequences ;"
            "IN: classes.mixin.tests"
            "MIXIN: mixin-forget-test"
            "INSTANCE: sequence mixin-forget-test"
            "GENERIC: mixin-forget-test-g ( x -- y )"
            "M: mixin-forget-test mixin-forget-test-g ;"
        } "\n" join <string-reader> "mixin-forget-test"
        parse-stream drop
    ] unit-test
    
    [ { } ] [ { } "mixin-forget-test-g" "classes.mixin.tests" lookup execute ] unit-test
    [ H{ } "mixin-forget-test-g" "classes.mixin.tests" lookup execute ] must-fail
    
    [ ] [
        {
            "USING: hashtables ;"
            "IN: classes.mixin.tests"
            "MIXIN: mixin-forget-test"
            "INSTANCE: hashtable mixin-forget-test"
            "GENERIC: mixin-forget-test-g ( x -- y )"
            "M: mixin-forget-test mixin-forget-test-g ;"
        } "\n" join <string-reader> "mixin-forget-test"
        parse-stream drop
    ] unit-test
    
    [ { } "mixin-forget-test-g" "classes.mixin.tests" lookup execute ] must-fail
    [ H{ } ] [ H{ } "mixin-forget-test-g" "classes.mixin.tests" lookup execute ] unit-test
] times

! Method flattening interfered with mixin update
MIXIN: flat-mx-1
TUPLE: flat-mx-1-1 ; INSTANCE: flat-mx-1-1 flat-mx-1
TUPLE: flat-mx-1-2 ; INSTANCE: flat-mx-1-2 flat-mx-1
TUPLE: flat-mx-1-3 ; INSTANCE: flat-mx-1-3 flat-mx-1
TUPLE: flat-mx-1-4 ; INSTANCE: flat-mx-1-4 flat-mx-1
MIXIN: flat-mx-2     INSTANCE: flat-mx-2 flat-mx-1
TUPLE: flat-mx-2-1 ; INSTANCE: flat-mx-2-1 flat-mx-2

[ t ] [ T{ flat-mx-2-1 } flat-mx-1? ] unit-test

! Too eager with reset-class

[ ] [ "IN: classes.mixin.tests MIXIN: blah SINGLETON: boo INSTANCE: boo blah" <string-reader> "mixin-reset-test" parse-stream drop ] unit-test

[ t ] [ "blah" "classes.mixin.tests" lookup mixin-class? ] unit-test

[ ] [ "IN: classes.mixin.tests MIXIN: blah" <string-reader> "mixin-reset-test" parse-stream drop ] unit-test

[ t ] [ "blah" "classes.mixin.tests" lookup mixin-class? ] unit-test

MIXIN: empty-mixin

[ f ] [ "hi" empty-mixin? ] unit-test

MIXIN: move-instance-declaration-mixin

[ ] [ "IN: classes.mixin.tests.a USE: strings USE: classes.mixin.tests INSTANCE: string move-instance-declaration-mixin" <string-reader> "move-mixin-test-1" parse-stream drop ] unit-test

[ ] [ "IN: classes.mixin.tests.b USE: strings USE: classes.mixin.tests INSTANCE: string move-instance-declaration-mixin" <string-reader> "move-mixin-test-2" parse-stream drop ] unit-test

[ ] [ "IN: classes.mixin.tests.a" <string-reader> "move-mixin-test-1" parse-stream drop ] unit-test

[ { string } ] [ move-instance-declaration-mixin members ] unit-test
