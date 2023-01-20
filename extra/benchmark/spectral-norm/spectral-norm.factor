! Copyright (C) 2008, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
!
! Factor port of
! https://shootout.alioth.debian.org/gp4/benchmark.php?test=spectralnorm&lang=all
USING: alien.c-types io kernel math math.functions math.parser
math.vectors sequences sequences.private specialized-arrays
typed locals ;
SPECIALIZED-ARRAY: double
IN: benchmark.spectral-norm

:: inner-loop ( u n quot -- seq )
    n <iota> [| i |
        n <iota> 0.0 [| j |
            u i j quot call +
        ] reduce
    ] double-array{ } map-as ; inline

: eval-A ( i j -- n )
    [ >float ] bi@
    [ drop ] [ + [ ] [ 1 + ] bi * 0.5 * ] 2bi
    + 1 + recip ; inline

: (eval-A-times-u) ( u i j -- x )
    [ swap nth-unsafe ] [ eval-A ] bi-curry bi* * ; inline

: eval-A-times-u ( n u -- seq )
    [ (eval-A-times-u) ] inner-loop ; inline

: (eval-At-times-u) ( u i j -- x )
    [ swap nth-unsafe ] [ swap eval-A ] bi-curry bi* * ; inline

: eval-At-times-u ( u n -- seq )
    [ (eval-At-times-u) ] inner-loop ; inline

: eval-AtA-times-u ( u n -- seq )
    [ eval-A-times-u ] [ eval-At-times-u ] bi ; inline

: ones ( n -- seq ) [ 1.0 ] double-array{ } replicate-as ; inline

:: u/v ( n -- u v )
    n ones dup
    10 [
        drop
        n eval-AtA-times-u
        [ n eval-AtA-times-u ] keep
    ] times ; inline

TYPED: spectral-norm ( n: fixnum -- norm )
    u/v [ vdot ] [ norm-sq ] bi /f sqrt ;

: spectral-norm-benchmark ( -- )
    2000 spectral-norm number>string print ;

MAIN: spectral-norm-benchmark
