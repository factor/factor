! Copyright (C) 2010 Marc Fauconneau.
! See https://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.data specialized-arrays kernel math
math.functions math.vectors sequences sequences.private
prettyprint words typed locals math.vectors.simd
math.vectors.simd.cords ;
SPECIALIZED-ARRAYS: double double-4 ;
IN: benchmark.spectral-norm-simd

:: inner-loop ( u n quot -- seq )
    n 4 /i <iota> [| i |
        n <iota> [| j | u i j quot call ] [ v+ ] map-reduce
    ] double-4-array{ } map-as ; inline

: eval-A ( i j -- n )
    [ >float ] bi@
    [ drop ] [ + [ ] [ 1 + ] bi * 0.5 * ] 2bi
    + 1 + ; inline

: vrecip ( u -- v ) double-4{ 1.0 1.0 1.0 1.0 } swap v/ ; inline

:: eval4-A ( i j -- n )
    i 4 * 0 + j eval-A
    i 4 * 1 + j eval-A
    i 4 * 2 + j eval-A
    i 4 * 3 + j eval-A
    double-4-boa vrecip ; inline

: (eval-A-times-u) ( u i j -- x )
    [ swap nth-unsafe ] [ eval4-A ] bi-curry bi* n*v ; inline

: eval-A-times-u ( n u -- seq )
    [ (eval-A-times-u) ] inner-loop ; inline

:: eval4-A' ( i j -- n )
    j i 4 * 0 + eval-A
    j i 4 * 1 + eval-A
    j i 4 * 2 + eval-A
    j i 4 * 3 + eval-A
    double-4-boa vrecip ; inline

: (eval-At-times-u) ( u i j -- x )
    [ swap nth-unsafe ] [ eval4-A' ] bi-curry bi* n*v ; inline

: eval-At-times-u ( u n -- seq )
    [ double cast-array ] dip [ (eval-At-times-u) ] inner-loop ; inline

: eval-AtA-times-u ( u n -- seq )
    [ double cast-array ] dip [ eval-A-times-u ] [ eval-At-times-u ] bi ; inline

: ones ( n -- seq )
    4 /i [ double-4{ 1.0 1.0 1.0 1.0 } ] double-4-array{ } replicate-as ; inline

:: u/v ( n -- u v )
    n ones dup
    10 [
        drop
        n eval-AtA-times-u
        [ n eval-AtA-times-u ] keep
    ] times ; inline

TYPED: spectral-norm ( n: fixnum -- norm )
    u/v [ double cast-array ] bi@ [ vdot ] [ norm-sq ] bi /f sqrt ;

: spectral-norm-simd-benchmark ( -- )
    2000 spectral-norm . ;

MAIN: spectral-norm-simd-benchmark
