USING: alien arrays definitions generic assocs hashtables io
io.streams.string kernel math namespaces parser prettyprint
sequences strings tools.test vectors words quotations classes
classes.private classes.union classes.mixin classes.predicate
classes.algebra vectors definitions source-files compiler.units
kernel.private sorting vocabs memory eval accessors ;
IN: classes.tests

[ t ] [ 3 object instance? ] unit-test
[ t ] [ 3 fixnum instance? ] unit-test
[ f ] [ 3 float instance? ] unit-test
[ t ] [ 3 number instance? ] unit-test
[ f ] [ 3 null instance? ] unit-test
[ t ] [ "hi" \ hi-tag instance? ] unit-test

! Regression
GENERIC: method-forget-test ( obj -- obj )
TUPLE: method-forget-class ;
M: method-forget-class method-forget-test ;

[ f ] [ \ method-forget-test "methods" word-prop assoc-empty? ] unit-test
[ ] [ [ \ method-forget-class forget ] with-compilation-unit ] unit-test
[ t ] [ \ method-forget-test "methods" word-prop assoc-empty? ] unit-test

[ t ] [
    all-words [ class? ] filter
    implementors-map get keys
    [ natural-sort ] bi@ =
] unit-test

! Minor leak
[ ] [ "IN: classes.tests TUPLE: forget-me ;" eval( -- ) ] unit-test
[ ] [ f \ word set-global ] unit-test
[ ] [ "IN: classes.tests USE: kernel USE: classes.algebra forget-me tuple class<= drop" eval( -- ) ] unit-test
[ ] [ "IN: classes.tests FORGET: forget-me" eval( -- ) ] unit-test
[ 0 ] [
    [ word? ] instances
    [ [ name>> "forget-me" = ] [ vocabulary>> "classes.tests" = ] bi and ] count
] unit-test

! Long-standing problem
USE: multiline

! So the user has some code...
[ ] [
    <" IN: classes.test.a
    GENERIC: g ( a -- b )
    TUPLE: x ;
    M: x g ;
    TUPLE: z < x ;"> <string-reader>
    "class-intersect-no-method-a" parse-stream drop
] unit-test

! Note that q inlines M: x g ;
[ ] [
    <" IN: classes.test.b
    USE: classes.test.a
    USE: kernel
    : q ( -- b ) z new g ;"> <string-reader>
    "class-intersect-no-method-b" parse-stream drop
] unit-test

! Now, the user removes the z class and adds a method,
[ ] [
    <" IN: classes.test.a
    GENERIC: g ( a -- b )
    TUPLE: x ;
    M: x g ;
    TUPLE: j ;
    M: j g ;"> <string-reader>
    "class-intersect-no-method-a" parse-stream drop
] unit-test

! And changes the definition of q
[ ] [
    <" IN: classes.test.b
    USE: classes.test.a
    USE: kernel
    : q ( -- b ) j new g ;"> <string-reader>
    "class-intersect-no-method-b" parse-stream drop
] unit-test

! Similar problem, but with anonymous classes
[ ] [
    <" IN: classes.test.c
    USE: kernel
    GENERIC: g ( a -- b )
    M: object g ;
    TUPLE: z ;"> <string-reader>
    "class-intersect-no-method-c" parse-stream drop
] unit-test

[ ] [
    <" IN: classes.test.d
    USE: classes.test.c
    USE: kernel
    : q ( a -- b ) dup z? [ g ] unless ;"> <string-reader>
    "class-intersect-no-method-d" parse-stream drop
] unit-test

! Now, the user removes the z class and adds a method,
[ ] [
    <" IN: classes.test.c
    USE: kernel
    GENERIC: g ( a -- b )
    M: object g ;
    TUPLE: j ;
    M: j g ;"> <string-reader>
    "class-intersect-no-method-c" parse-stream drop
] unit-test

TUPLE: forgotten-predicate-test ;

[ ] [ [ \ forgotten-predicate-test forget ] with-compilation-unit ] unit-test
[ f ] [ \ forgotten-predicate-test? predicate? ] unit-test
