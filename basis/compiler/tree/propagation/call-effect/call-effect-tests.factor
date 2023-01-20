! Copyright (C) 2009 Slava Pestov, Daniel Ehrenberg.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors combinators combinators.private compiler.test
compiler.tree compiler.tree.builder compiler.tree.debugger
compiler.tree.optimizer compiler.tree.propagation.call-effect
compiler.tree.propagation.info
compiler.units effects eval fry kernel kernel.private math sequences
tools.test ;
IN: compiler.tree.propagation.call-effect.tests

! cached-effect
{ t } [ [ + ] cached-effect ( a b -- c ) effect= ] unit-test
{ t } [ 5 [ + ] curry cached-effect ( a -- c ) effect= ] unit-test
{ t } [ 5 [ ] curry cached-effect ( -- c ) effect= ] unit-test
{ t } [ [ dup ] [ drop ] compose cached-effect ( a -- b ) effect= ] unit-test
{ t } [ [ drop ] [ dup ] compose cached-effect ( a b -- c d ) effect= ] unit-test
{ t } [ [ 2drop ] [ dup ] compose cached-effect ( a b c -- d e ) effect= ] unit-test
{ t } [ [ 1 2 3 ] [ 2drop ] compose cached-effect ( -- a ) effect= ] unit-test
{ t } [ [ 1 2 ] [ 3drop ] compose cached-effect ( a -- ) effect= ] unit-test

! call-effect>quot
{
    [ drop ( a -- b ) T{ inline-cache } call-effect-ic ]
} [
    ( a -- b ) call-effect>quot
] unit-test

! call-effect-slow>quot
{ 10000 } [
    100 [ sq ] ( a -- b ) call-effect-slow>quot call
] unit-test

{
    [
        [
            ( -- a b c )
            2dup
            [
                [ [ get-datastack ] dip dip ] dip dup terminated?>>
                [ 2drop f ] [
                    dup in>> length swap out>> length
                    check-datastack
                ] if
            ]
            2dip
            rot
            [ 2drop ]
            [ wrong-values ]
            if
        ]
        ( obj -- a b c )
        call-effect-unsafe
    ]
} [
    ( -- a b c ) call-effect-slow>quot
] unit-test

! call-effect-unsafe?
{ f t } [
    [ ] ( m -- ) call-effect-unsafe?
    [ ] ( x -- x ) call-effect-unsafe?
] unit-test

! call-inlining
{
    [ drop f T{ inline-cache } call-effect-ic ]
} [
    T{ #call
       { word call-effect }
       { in-d V{ 165186755 165186756 165186754 } }
       { out-d { 165186757 } }
    } call-inlining
] unit-test

! execute-effect-unsafe?
{ t } [ \ + ( a b -- c ) execute-effect-unsafe? ] unit-test
{ t } [ \ + ( a b c -- d e ) execute-effect-unsafe? ] unit-test
{ f } [ \ + ( a b c -- d ) execute-effect-unsafe? ] unit-test
{ f } [ \ call ( x -- ) execute-effect-unsafe? ] unit-test

! update-inline-cache
{ t } [
    [ boa ] inline-cache new [ update-inline-cache ] keep
    [ boa ] effect-counter inline-cache boa =
] unit-test


: optimized-quot ( quot -- quot' )
    build-tree optimize-tree nodes>quot ;

: compiled-call2 ( a quot: ( a -- b ) -- b )
    call( a -- b ) ;

: compiled-execute2 ( a b word: ( a b -- c ) -- c )
    execute( a b -- c ) ;

{ [ 3 ] } [ [ 1 2 \ + execute( a b -- c ) ] optimized-quot ] unit-test
{ [ 3 ] } [ [ 1 2 [ + ] call( a b -- c ) ] optimized-quot ] unit-test
{ [ 3 ] } [ [ 1 2 '[ _ + ] call( a -- b ) ] optimized-quot ] unit-test
{ [ 3 ] } [ [ 1 2 '[ _ ] [ + ] compose call( a -- b ) ] optimized-quot ] unit-test

[ 1 2 { [ + ] } first compiled-call2 ] must-fail
{ 3 } [ 1 2 { + } first compiled-execute2 ] unit-test
{ 3 } [ 1 2 '[ _ + ] compiled-call2 ] unit-test
{ 3 } [ 1 2 '[ _ ] [ + ] compose compiled-call2 ] unit-test
{ 3 } [ 1 2 \ + compiled-execute2 ] unit-test

{ 3 } [ 1 2 { [ + ] } first call( a b -- c ) ] unit-test
{ 3 } [ 1 2 { + } first execute( a b -- c ) ] unit-test
{ 3 } [ 1 2 '[ _ + ] call( a -- b ) ] unit-test
{ 3 } [ 1 2 '[ _ ] [ + ] compose call( a -- b ) ] unit-test

{ t } [ [ 2 '[ _ ] [ + ] compose ] final-info first infer-value ( object -- object ) effect= ] unit-test
{ t } [ [ 2 '[ _ ] 1 '[ _ + ] compose ] final-info first infer-value ( -- object ) effect= ] unit-test
{ t } [ [ 2 '[ _ + ] ] final-info first infer-value ( object -- object ) effect= ] unit-test
{ f } [ [ [ [ ] [ 1 ] if ] ] final-info first infer-value ] unit-test
{ t } [ [ [ 1 ] '[ @ ] ] final-info first infer-value ( -- object ) effect= ] unit-test
{ f } [ [ dup drop ] final-info first infer-value ] unit-test

! This should not hang
[ [ [ dup call( quot -- ) ] dup call( quot -- ) ] final-info ] must-not-fail
[ [ [ dup curry call( quot -- ) ] dup curry call( quot -- ) ] final-info ] must-not-fail

! This should get inlined, because the parameter to the curry is literal even though
! [ boa ] by itself doesn't infer
TUPLE: a-tuple x ;

{ V{ a-tuple } } [ [ a-tuple '[ _ boa ] call( x -- tuple ) ] final-classes ] unit-test

! See if redefinitions are handled correctly
: call(-redefine-test ( a -- b ) 1 + ;

: test-quotatation ( -- quot ) [ call(-redefine-test ] ;

{ t } [ test-quotatation cached-effect ( a -- b ) effect<= ] unit-test

{ } [ "IN: compiler.tree.propagation.call-effect.tests USE: math : call(-redefine-test ( a b -- c ) + ;" eval( -- ) ] unit-test

{ t } [ test-quotatation cached-effect ( a b -- c ) effect<= ] unit-test

: inline-cache-invalidation-test ( a b c -- c ) call( a b -- c ) ;

{ 4 } [ 1 3 test-quotatation inline-cache-invalidation-test ] unit-test

{ } [ "IN: compiler.tree.propagation.call-effect.tests USE: math : call(-redefine-test ( a -- c ) 1 + ;" eval( -- ) ] unit-test

[ 1 3 test-quotatation inline-cache-invalidation-test ] [ T{ wrong-values f [ call(-redefine-test ] ( a b -- c ) } = ] must-fail-with

! See if redefining a tuple class bumps effect counter
TUPLE: my-tuple a b c ;

: my-quot ( -- quot ) [ my-tuple boa ] ;

: my-word ( a b c q -- result ) call( a b c -- result ) ;

{ T{ my-tuple f 1 2 3 } } [ 1 2 3 my-quot my-word ] unit-test

{ } [ "IN: compiler.tree.propagation.call-effect.tests TUPLE: my-tuple a b ;" eval( -- ) ] unit-test

[ 1 2 3 my-quot my-word ] [ wrong-values? ] must-fail-with

! Regression
[ composed <class-info> (infer-value) ] [ uninferable? ] must-fail-with
{ t } [ [ 1 ] [ 2 ] compose <literal-info> (infer-value) ( -- x x ) effect= ] unit-test
{ } [ "IN: compiler.tree.propagation.call-effect.tests USING:
kernel kernel.private ; : blub ( x -- ) { composed } declare call( -- ) ;" eval( -- ) ] unit-test
