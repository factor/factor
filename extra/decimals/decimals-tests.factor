! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: continuations decimals grouping kernel literals locals
math math.functions math.order math.ratios prettyprint random
sequences tools.test ;
IN: decimals.tests

[ t ] [
    D: 12.34 D: 00012.34000 =
] unit-test

: random-test-int ( -- n )
    10 random 2 random 0 = [ neg ] when ;

: random-test-decimal ( -- decimal )
    random-test-int random-test-int <decimal> ;

ERROR: decimal-test-failure D1 D2 quot ;

:: (test-decimal-op) ( D1 D2 quot1 quot2 -- ? )
    D1 D2
    quot1 [ decimal>ratio >float ] compose
    [ [ decimal>ratio ] bi@ quot2 call( obj obj -- obj ) >float ] 2bi -.1 ~
    [ t ] [ D1 D2 quot1 decimal-test-failure ] if ; inline

: test-decimal-op ( quot1 quot2 -- ? )
    [ random-test-decimal random-test-decimal ] 2dip (test-decimal-op) ; inline

[ t ] [ 1000 [ drop [ D+ ] [ + ] test-decimal-op ] all-integers? ] unit-test
[ t ] [ 1000 [ drop [ D- ] [ - ] test-decimal-op ] all-integers? ] unit-test
[ t ] [ 1000 [ drop [ D* ] [ * ] test-decimal-op ] all-integers? ] unit-test
[ t ] [
    1000 [
        drop
        [ [ 100 D/ ] [ /f ] test-decimal-op ]
        [ ${ "kernel-error" ERROR-DIVIDE-BY-ZERO f f } = ] recover
    ] all-integers?
] unit-test

[ t ] [
    { D: 0. D: .0 D: 0.0 D: 00.00 D: . } all-equal?
] unit-test

[ t ] [ T{ decimal f 90 0 } T{ decimal f 9 1 } = ] unit-test

[ t ] [ D: 1 D: 2 before? ] unit-test
[ f ] [ D: 2 D: 2 before? ] unit-test
[ f ] [ D: 3 D: 2 before? ] unit-test
[ f ] [ D: -1 D: -2 before? ] unit-test
[ f ] [ D: -2 D: -2 before? ] unit-test
[ t ] [ D: -3 D: -2 before? ] unit-test
[ t ] [ D: .5 D: 0 D: 1.0 between? ] unit-test
