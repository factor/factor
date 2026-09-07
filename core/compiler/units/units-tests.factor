USING: arrays compiler compiler.units compiler.units.private
continuations definitions eval fry
kernel math namespaces quotations sequences tools.test
vocabs.loader words ;
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

! #67: installing a nested caller can reference a word that is still new
! in an enclosing unit. Its call site must be patched when that unit ends.
{ 17 } [
    [
        [
            gensym dup [ 17 ] ( -- n ) define-declared
            [ 1quotation ( -- n ) define-temp ] with-compilation-unit
        ] with-compilation-unit execute( -- n )
    ] without-optimizer
] unit-test

! Refreshing an older image can reload this vocab while an old unit's
! nesting observer is still registered. Its method and cleanup must survive.
{ t } [
    definition-observers get length
    [
        add-nesting-observer
        [ "compiler.units" reload ]
        [ remove-nesting-observer ] finally
    ] with-compilation-unit
    definition-observers get length =
] unit-test

! The invalidation must reach all enclosing units, including across an
! intermediate unit that does not itself define any words.
{ 23 } [
    [
        [
            gensym dup [ 23 ] ( -- n ) define-declared
            [
                [ 1quotation ( -- n ) define-temp ] with-compilation-unit
            ] with-compilation-unit
        ] with-compilation-unit execute( -- n )
    ] without-optimizer
] unit-test

{ 31 } [
    [
        gensym dup [ 31 ] ( -- n ) define-declared
        [ 1quotation ( -- n ) define-temp ] with-compilation-unit
    ] with-compilation-unit execute( -- n )
] unit-test

! Explicit compilation can also install a caller before its unit finishes.
! Keep a quotation pointing at that installed caller across the final update.
{ 41 } [
    [
        [
            gensym dup [ 41 ] ( -- n ) define-declared
            1quotation ( -- n ) define-temp
            dup 1array compile
            1quotation dup jit-compile
        ] with-compilation-unit call( -- n )
    ] without-optimizer
] unit-test

! A nested unit installs definitions in its cleanup even if its body throws.
{ 53 } [
    [
        [
            gensym dup [ 53 ] ( -- n ) define-declared
            [
                [ 1quotation ( -- n ) define-temp throw ]
                with-compilation-unit
            ] [ nip ] recover
        ] with-compilation-unit execute( -- n )
    ] without-optimizer
] unit-test

! Changing the dynamic namespace must not hide other unfinished units.
{ 59 } [
    [
        [
            gensym dup [ 59 ] ( -- n ) define-declared
            [
                [
                    [ 1quotation ( -- n ) define-temp ] with-compilation-unit
                ] without-optimizer
            ] with-global
        ] with-compilation-unit execute( -- n )
    ] without-optimizer
] unit-test

! Parser definition bookkeeping is shared by nested units. An empty unit
! must not make its parent's new definitions look like installed code.
{ f } [
    [
        gensym dup [ 17 ] ( -- n ) define-declared
        dup f remember-definition
        [ ] with-nested-compilation-unit
        1array update-existing?
    ] with-compilation-unit
] unit-test
