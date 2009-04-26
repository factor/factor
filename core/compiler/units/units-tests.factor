USING: compiler definitions compiler.units tools.test arrays sequences words kernel
accessors namespaces fry eval ;
IN: compiler.units.tests

[ [ [ ] define-temp ] with-compilation-unit ] must-infer
[ [ [ ] define-temp ] with-nested-compilation-unit ] must-infer

[ flushed-dependency ] [ f flushed-dependency strongest-dependency ] unit-test
[ flushed-dependency ] [ flushed-dependency f strongest-dependency ] unit-test
[ inlined-dependency ] [ flushed-dependency inlined-dependency strongest-dependency ] unit-test
[ inlined-dependency ] [ called-dependency inlined-dependency strongest-dependency ] unit-test
[ flushed-dependency ] [ called-dependency flushed-dependency strongest-dependency ] unit-test
[ called-dependency ] [ called-dependency f strongest-dependency ] unit-test

! Non-optimizing compiler bugs
[ 1 1 ] [
    "A" "B" <word> [ [ [ 1 ] dip ] 2array 1array modify-code-heap ] keep
    1 swap execute
] unit-test

[ "A" "B" ] [
    disable-compiler

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

    enable-compiler
] unit-test

! Check that we notify observers
SINGLETON: observer

observer add-definition-observer

SYMBOL: counter

0 counter set-global

M: observer definitions-changed 2drop global [ counter inc ] bind ;

[ gensym [ ] (( -- )) define-declared ] with-compilation-unit

[ 1 ] [ counter get-global ] unit-test

observer remove-definition-observer

! Notify observers with nested compilation units
observer add-definition-observer

0 counter set-global

DEFER: nesting-test

[ ] [ "IN: compiler.units.tests << : nesting-test ( -- ) ; >>" eval( -- ) ] unit-test

observer remove-definition-observer
