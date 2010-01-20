! Copyright (C) 2009 Slava Pestov, Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: compiler.tree.propagation.call-effect tools.test fry math effects kernel
compiler.tree.builder compiler.tree.optimizer compiler.tree.debugger sequences
eval combinators ;
IN: compiler.tree.propagation.call-effect.tests

[ t ] [ \ + (( a b -- c )) execute-effect-unsafe? ] unit-test
[ t ] [ \ + (( a b c -- d e )) execute-effect-unsafe? ] unit-test
[ f ] [ \ + (( a b c -- d )) execute-effect-unsafe? ] unit-test
[ f ] [ \ call (( x -- )) execute-effect-unsafe? ] unit-test

[ t ] [ [ + ] cached-effect (( a b -- c )) effect= ] unit-test
[ t ] [ 5 [ + ] curry cached-effect (( a -- c )) effect= ] unit-test
[ t ] [ 5 [ ] curry cached-effect (( -- c )) effect= ] unit-test
[ t ] [ [ dup ] [ drop ] compose cached-effect (( a -- b )) effect= ] unit-test
[ t ] [ [ drop ] [ dup ] compose cached-effect (( a b -- c d )) effect= ] unit-test
[ t ] [ [ 2drop ] [ dup ] compose cached-effect (( a b c -- d e )) effect= ] unit-test
[ t ] [ [ 1 2 3 ] [ 2drop ] compose cached-effect (( -- a )) effect= ] unit-test
[ t ] [ [ 1 2 ] [ 3drop ] compose cached-effect (( a -- )) effect= ] unit-test

: optimized-quot ( quot -- quot' )
    build-tree optimize-tree nodes>quot ;

: compiled-call2 ( a quot: ( a -- b ) -- b )
    call( a -- b ) ;

: compiled-execute2 ( a b word: ( a b -- c ) -- c )
    execute( a b -- c ) ;

[ [ 3 ] ] [ [ 1 2 \ + execute( a b -- c ) ] optimized-quot ] unit-test
[ [ 3 ] ] [ [ 1 2 [ + ] call( a b -- c ) ] optimized-quot ] unit-test
[ [ 3 ] ] [ [ 1 2 '[ _ + ] call( a -- b ) ] optimized-quot ] unit-test
[ [ 3 ] ] [ [ 1 2 '[ _ ] [ + ] compose call( a -- b ) ] optimized-quot ] unit-test

[ 1 2 { [ + ] } first compiled-call2 ] must-fail
[ 3 ] [ 1 2 { + } first compiled-execute2 ] unit-test
[ 3 ] [ 1 2 '[ _ + ] compiled-call2 ] unit-test
[ 3 ] [ 1 2 '[ _ ] [ + ] compose compiled-call2 ] unit-test
[ 3 ] [ 1 2 \ + compiled-execute2 ] unit-test

[ 3 ] [ 1 2 { [ + ] } first call( a b -- c ) ] unit-test
[ 3 ] [ 1 2 { + } first execute( a b -- c ) ] unit-test
[ 3 ] [ 1 2 '[ _ + ] call( a -- b ) ] unit-test
[ 3 ] [ 1 2 '[ _ ] [ + ] compose call( a -- b ) ] unit-test

[ t ] [ [ 2 '[ _ ] [ + ] compose ] final-info first infer-value (( object -- object )) effect= ] unit-test
[ t ] [ [ 2 '[ _ ] 1 '[ _ + ] compose ] final-info first infer-value (( -- object )) effect= ] unit-test
[ t ] [ [ 2 '[ _ + ] ] final-info first infer-value (( object -- object )) effect= ] unit-test
[ f ] [ [ [ [ ] [ 1 ] if ] ] final-info first infer-value ] unit-test
[ t ] [ [ [ 1 ] '[ @ ] ] final-info first infer-value (( -- object )) effect= ] unit-test
[ f ] [ [ dup drop ] final-info first infer-value ] unit-test

! This should not hang
[ ] [ [ [ dup call( quot -- ) ] dup call( quot -- ) ] final-info drop ] unit-test
[ ] [ [ [ dup curry call( quot -- ) ] dup curry call( quot -- ) ] final-info drop ] unit-test

! This should get inlined, because the parameter to the curry is literal even though
! [ boa ] by itself doesn't infer
TUPLE: a-tuple x ;

[ V{ a-tuple } ] [ [ a-tuple '[ _ boa ] call( x -- tuple ) ] final-classes ] unit-test

! See if redefinitions are handled correctly
: call(-redefine-test ( a -- b ) 1 + ;

: test-quotatation ( -- quot ) [ call(-redefine-test ] ;

[ t ] [ test-quotatation cached-effect (( a -- b )) effect<= ] unit-test

[ ] [ "IN: compiler.tree.propagation.call-effect.tests USE: math : call(-redefine-test ( a b -- c ) + ;" eval( -- ) ] unit-test

[ t ] [ test-quotatation cached-effect (( a b -- c )) effect<= ] unit-test

: inline-cache-invalidation-test ( a b c -- c ) call( a b -- c ) ;

[ 4 ] [ 1 3 test-quotatation inline-cache-invalidation-test ] unit-test

[ ] [ "IN: compiler.tree.propagation.call-effect.tests USE: math : call(-redefine-test ( a -- c ) 1 + ;" eval( -- ) ] unit-test

[ 1 3 test-quotatation inline-cache-invalidation-test ] [ T{ wrong-values f (( a b -- c )) } = ] must-fail-with
