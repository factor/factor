USING: destructors kernel tools.test continuations accessors
namespaces sequences ;
IN: destructors.tests

TUPLE: dispose-error ;

M: dispose-error dispose 3 throw ;

TUPLE: dispose-dummy disposed? ;

M: dispose-dummy dispose t >>disposed? drop ;

T{ dispose-error } "a" set
T{ dispose-dummy } "b" set

[ f ] [ "b" get disposed?>> ] unit-test

[ { "a" "b" } [ get ] map dispose-each ] [ 3 = ] must-fail-with

[ t ] [ "b" get disposed?>> ] unit-test

TUPLE: dummy-obj destroyed? ;

: <dummy-obj> dummy-obj new ;

TUPLE: dummy-destructor obj ;

C: <dummy-destructor> dummy-destructor

M: dummy-destructor dispose ( obj -- )
    dummy-destructor-obj t swap set-dummy-obj-destroyed? ;

: destroy-always
    <dummy-destructor> &dispose drop ;

: destroy-later
    <dummy-destructor> |dispose drop ;

[ t ] [
    [
        <dummy-obj> dup destroy-always
    ] with-destructors dummy-obj-destroyed? 
] unit-test

[ f ] [
    [
        <dummy-obj> dup destroy-later
    ] with-destructors dummy-obj-destroyed? 
] unit-test

[ t ] [
    <dummy-obj> [
        [
            dup destroy-always
            "foo" throw
        ] with-destructors
    ] ignore-errors dummy-obj-destroyed? 
] unit-test

[ t ] [
    <dummy-obj> [
        [
            dup destroy-later
            "foo" throw
        ] with-destructors
    ] ignore-errors dummy-obj-destroyed? 
] unit-test

