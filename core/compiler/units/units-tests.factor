USING: arrays compiler compiler.units definitions eval fry
kernel math namespaces quotations sequences tools.test words ;
IN: compiler.units.tests

[ [ [ ] define-temp ] with-compilation-unit ] must-infer
[ [ [ ] define-temp ] with-nested-compilation-unit ] must-infer

! Non-optimizing compiler bugs
{ 1 1 } [
    "A" <uninterned-word> [ [ [ 1 ] dip ] 2array 1array t t modify-code-heap ] keep
    1 swap execute
] unit-test

{ "A" "B" } [
    disable-optimizer

    gensym "a" set
    gensym "b" set
    [
        "a" get [ "A" ] define
        "b" get "a" get '[ _ execute ] define
    ] with-compilation-unit
    "b" get execute
    [
        "a" get [ "B" ] define
    ] with-compilation-unit
    "b" get execute

    enable-optimizer
] unit-test

! Check that we notify observers
SINGLETON: observer

observer add-definition-observer

SYMBOL: counter

0 counter set-global

M: observer definitions-changed
    2drop [ counter inc ] with-global ;

[ gensym [ ] ( -- ) define-declared ] with-compilation-unit

{ 1 } [ counter get-global ] unit-test

observer remove-definition-observer

! Notify observers with nested compilation units
observer add-definition-observer

0 counter set-global

DEFER: nesting-test

{ } [ "IN: compiler.units.tests << : nesting-test ( -- ) ; >>" eval( -- ) ] unit-test

observer remove-definition-observer

! Make sure that non-optimized calls to a generic word which
! hasn't been compiled yet work properly
GENERIC: uncompiled-generic-test ( a -- b )

M: integer uncompiled-generic-test 1 + ;

<< [ uncompiled-generic-test ] [ jit-compile ] [ suffix! ] bi >>
"q" set

{ 4 } [ 3 "q" get call ] unit-test

{ } [ [ \ uncompiled-generic-test forget ] with-compilation-unit ] unit-test
