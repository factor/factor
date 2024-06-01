USING: accessors continuations destructors destructors.private
kernel math namespaces sequences tools.test ;
IN: destructors.tests

TUPLE: dispose-error ;

M: dispose-error dispose 3 throw ;

TUPLE: dispose-dummy disposed n ;

M: dispose-dummy dispose* [ 0 or 1 + ] change-n drop ;

T{ dispose-error } "a" set
T{ dispose-dummy } "b" set

{ f f } [ "b" get [ disposed>> ] [ n>> ] bi ] unit-test

[ { "a" "b" } [ get ] map dispose-each ] [ 3 = ] must-fail-with

{ t 1 } [ "b" get [ disposed>> ] [ n>> ] bi ] unit-test

{ 1 } [ "b" get [ dispose ] [ dispose ] [ n>> ] tri ] unit-test

TUPLE: dummy-obj destroyed? ;

: <dummy-obj> ( -- obj ) dummy-obj new ;

TUPLE: dummy-destructor obj ;

C: <dummy-destructor> dummy-destructor

M: dummy-destructor dispose ( obj -- )
    obj>> t >>destroyed? drop ;

: destroy-always ( obj -- )
    <dummy-destructor> &dispose drop ;

: destroy-later ( obj -- )
    <dummy-destructor> |dispose drop ;

{ t } [
    [
        <dummy-obj> dup destroy-always
    ] with-destructors destroyed?>>
] unit-test

{ f } [
    [
        <dummy-obj> dup destroy-later
    ] with-destructors destroyed?>>
] unit-test

{ t } [
    <dummy-obj> [
        [
            dup destroy-always
            "foo" throw
        ] with-destructors
    ] ignore-errors destroyed?>>
] unit-test

{ t } [
    <dummy-obj> [
        [
            dup destroy-later
            "foo" throw
        ] with-destructors
    ] ignore-errors destroyed?>>
] unit-test

TUPLE: silly-disposable < disposable ;

M: silly-disposable dispose* drop ;

silly-disposable new-disposable "s" set
"s" get dispose
[ "s" get unregister-disposable ]
[ disposable>> silly-disposable? ]
must-fail-with

{ t "disposed" } [
    t 1 dispose-dummy boa
    [ t "disposed" ] [ "not disposed" ] if-disposed
] unit-test

{ T{ dispose-dummy f f } "not disposed" } [
    f f dispose-dummy boa
    [ t "disposed" ] [ "not disposed" ] if-disposed
] unit-test
