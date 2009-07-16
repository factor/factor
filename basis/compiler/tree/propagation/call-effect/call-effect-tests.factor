! Copyright (C) 2009 Slava Pestov, Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: compiler.tree.propagation.call-effect tools.test fry math effects kernel
compiler.tree.builder compiler.tree.optimizer compiler.tree.debugger sequences ;
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
[ f ] [ [ [ 1 ] '[ @ ] ] final-info first infer-value ] unit-test
[ f ] [ [ dup drop ] final-info first infer-value ] unit-test
