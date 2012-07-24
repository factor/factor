! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.data arrays assocs
byte-arrays byte-vectors combinators combinators.short-circuit
fry io.backend io.binary kernel locals math math.bitwise
math.constants math.functions math.order math.ranges namespaces
sequences sequences.private sets summary system vocabs hints
typed ;
IN: random

SYMBOL: system-random-generator
SYMBOL: secure-random-generator
SYMBOL: random-generator

GENERIC# seed-random 1 ( tuple seed -- tuple' )
GENERIC: random-32* ( tuple -- r )
GENERIC: random-bytes* ( n tuple -- byte-array )

M: object random-bytes* ( n tuple -- byte-array )
    [ [ <byte-vector> ] keep 4 /mod ] dip
    [ pick '[ _ random-32* int <ref> _ push-all ] times ]
    [
        over zero?
        [ 2drop ] [ random-32* int <ref> swap head append! ] if
    ] bi-curry bi* B{ } like ;

HINTS: M\ object random-bytes* { fixnum object } ;

M: object random-32* ( tuple -- r ) 4 swap random-bytes* be> ;

ERROR: no-random-number-generator ;

M: no-random-number-generator summary
    drop "Random number generator is not defined." ;

M: f random-bytes* ( n obj -- * ) no-random-number-generator ;

M: f random-32* ( obj -- * ) no-random-number-generator ;

: random-32 ( -- n ) random-generator get random-32* ;

TYPED: random-bytes ( n: fixnum -- byte-array: byte-array )
    random-generator get random-bytes* ; inline

<PRIVATE

: (random-integer) ( bits -- n required-bits )
    [ random-32 32 ] dip 32 - [ dup 0 > ] [
        [ 32 shift random-32 + ] [ 32 + ] [ 32 - ] tri*
    ] while drop ;

: random-integer ( n -- n' )
    dup next-power-of-2 log2 (random-integer)
    [ * ] [ 2^ /i ] bi* ;

PRIVATE>

: random-bits ( numbits -- r ) 2^ random-integer ;

: random-bits* ( numbits -- n )
    1 - [ random-bits ] keep set-bit ;

GENERIC: random ( obj -- elt )

M: integer random [ f ] [ random-integer ] if-zero ;

M: sequence random
    [ f ] [
        [ length random-integer ] keep nth
    ] if-empty ;

: randomize-n-last ( seq n -- seq )
    [ dup length dup ] dip - 1 max '[ dup _ > ]
    [ [ random ] [ 1 - ] bi [ pick exchange-unsafe ] keep ]
    while drop ;

: randomize ( seq -- randomized )
    dup length randomize-n-last ;

ERROR: too-many-samples seq n ;

: sample ( seq n -- seq' )
    2dup [ length ] dip < [ too-many-samples ] when
    [ [ length iota >array ] dip [ randomize-n-last ] keep tail-slice* ]
    [ drop ] 2bi nths ;

: delete-random ( seq -- elt )
    [ length random-integer ] keep [ nth ] 2keep remove-nth! drop ;

: with-random ( tuple quot -- )
    random-generator swap with-variable ; inline

: with-system-random ( quot -- )
    system-random-generator get swap with-random ; inline

: with-secure-random ( quot -- )
    secure-random-generator get swap with-random ; inline

: uniform-random-float ( min max -- n )
    4 random-bytes uint deref >float
    4 random-bytes uint deref >float
    2.0 32 ^ * +
    [ over - 2.0 -64 ^ * ] dip
    * + ; inline

: random-unit ( -- n )
    0.0 1.0 uniform-random-float ; inline

: (cos-random-float) ( -- n )
    0. 2pi uniform-random-float cos ;

: (log-sqrt-random-float) ( -- n )
    random-unit log -2. * sqrt ;

: normal-random-float ( mean sigma -- n )
    (cos-random-float) (log-sqrt-random-float) * * + ;

: lognormal-random-float ( mean sigma -- n )
    normal-random-float exp ;

: exponential-random-float ( lambda -- n )
    random-unit log neg swap / ;

: weibull-random-float ( alpha beta -- n )
    [
        [ random-unit log neg ] dip
        1. swap / ^
    ] dip * ;

: pareto-random-float ( alpha -- n )
    [ random-unit ] dip [ 1. swap / ] bi@ ^ ;

:: (gamma-random-float>1) ( alpha beta -- n )
    ! Uses R.C.H. Cheng, "The generation of Gamma
    ! variables with non-integral shape parameters",
    ! Applied Statistics, (1977), 26, No. 1, p71-74
    2. alpha * 1 - sqrt :> ainv
    alpha 4. log -      :> bbb
    alpha ainv +        :> ccc

    0 :> r! 0 :> z! 0 :> result! ! initialize locals
    [
        r {
            [ 1. 4.5 log + + z 4.5 * - 0 >= ]
            [ z log >= ]
        } 1|| not
    ] [
        random-unit :> u1
        random-unit :> u2

        u1 1. u1 - / log ainv / :> v
        alpha v exp *           :> x
        u1 sq u2 *              z!
        bbb ccc v * + x -       r!

        x beta *                result!
    ] do while result ;

: (gamma-random-float=1) ( alpha beta -- n )
    nip random-unit log neg * ;

:: (gamma-random-float<1) ( alpha beta -- n )
    ! Uses ALGORITHM GS of Statistical Computing - Kennedy & Gentle
    alpha e + e / :> b

    0 :> x! 0 :> p! ! initialize locals
    [
        p 1.0 > [
            random-unit x alpha 1 - ^ >
        ] [
            random-unit x neg exp >
        ] if
    ] [
        random-unit b * p!
        p 1.0 <= [
            p 1. alpha / ^
        ] [
            b p - alpha / log neg
        ] if x!
    ] do while x beta * ;

: gamma-random-float ( alpha beta -- n )
    {
        { [ over 1 > ] [ (gamma-random-float>1) ] }
        { [ over 1 = ] [ (gamma-random-float=1) ] }
        [ (gamma-random-float<1) ]
    } cond ;

: beta-random-float ( alpha beta -- n )
    [ 1. gamma-random-float ] dip over zero?
    [ 2drop 0 ] [ 1. gamma-random-float dupd + / ] if ;

:: von-mises-random-float ( mu kappa -- n )
    ! Based upon an algorithm published in: Fisher, N.I.,
    ! "Statistical Analysis of Circular Data", Cambridge
    ! University Press, 1993.
    kappa 1e-6 <= [
        2pi random-unit *
    ] [
        4. kappa sq * 1. + sqrt 1. + :> a
        a 2. a * sqrt - 2. kappa * / :> b
        b sq 1. + 2. b * /           :> r

        0 :> c! 0 :> _f! ! initialize locals
        [
            random-unit {
                [ 2. c - c * < ] [ 1. c - exp c * <= ]
            } 1|| not
        ] [
            random-unit pi * cos :> z
            r z * 1. + r z + /   _f!
            r _f - kappa *       c!
        ] do while

        mu 2pi mod _f cos random-unit 0.5 > [ + ] [ - ] if
    ] if ;

{
    { [ os windows? ] [ "random.windows" require ] }
    { [ os unix? ] [ "random.unix" require ] }
} cond

"random.mersenne-twister" require
