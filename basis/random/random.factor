! Copyright (C) 2008 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.data arrays assocs byte-arrays
combinators combinators.short-circuit hash-sets hashtables
hashtables.private kernel math math.bitwise math.constants
math.functions math.order namespaces sequences sequences.private
sets summary system vocabs ;
QUALIFIED-WITH: alien.c-types c
IN: random

USE: kernel.private

SYMBOL: system-random-generator
SYMBOL: secure-random-generator
SYMBOL: random-generator

GENERIC#: seed-random 1 ( rnd seed -- rnd )
GENERIC: random-32* ( rnd -- n )
GENERIC: random-bytes* ( n rnd -- byte-array )

M: object random-bytes*
    [ integer>fixnum-strict [ (byte-array) ] keep ] dip
    [ over 4 >= ] [
        [ 4 - ] dip
        [ random-32* 2over c:int c:set-alien-value ] keep
    ] while over zero? [ 2drop ] [
        random-32* c:int <ref> swap head 0 pick copy-unsafe
    ] if ;

M: object random-32*
    4 swap random-bytes* c:uint deref ;

ERROR: no-random-number-generator ;

M: no-random-number-generator summary
    drop "Random number generator is not defined." ;

M: f random-bytes* no-random-number-generator ;

M: f random-32* no-random-number-generator ;

: random-32 ( -- n )
    random-generator get random-32* ;

: random-bytes ( n -- byte-array )
    random-generator get random-bytes* ;

<PRIVATE

:: (random-bits) ( numbits rnd -- n )
    numbits 32 > [
        rnd random-32* numbits 32 - [ dup 32 > ] [
            [ 32 shift rnd random-32* + ] [ 32 - ] bi*
        ] while [
            [ shift ] keep rnd random-32* swap bits +
        ] unless-zero
    ] [
        rnd random-32* numbits bits
    ] if ; inline

PRIVATE>

: random-bits ( numbits -- n )
    random-generator get (random-bits) ;

: random-bits* ( numbits -- n )
    1 - [ random-bits ] keep set-bit ;

GENERIC#: random* 1 ( obj rnd -- elt )

: random ( obj -- elt )
    random-generator get random* ;

: randoms-as ( length obj exemplar -- seq )
    [ random-generator get '[ _ _ random* ] ] dip replicate-as ;

: randoms ( length obj -- seq ) { } randoms-as ;

<PRIVATE

: next-power-of-2-bits ( m -- numbits )
    dup 2 <= [ drop 1 ] [ 1 - log2 1 + ] if ; inline

:: random-integer ( m rnd -- n )
    m zero? [ f ] [
        rnd random-32* { integer } declare 32 m next-power-of-2-bits 32 - [ dup 0 > ] [
            [ 32 shift rnd random-32* { integer } declare + ] [ 32 + ] [ 32 - ] tri*
        ] while drop [ m * ] [ neg shift ] bi*
    ] if ; inline

PRIVATE>

M: fixnum random* random-integer ;

M: bignum random* random-integer ;

M: sequence random*
    [ f ] swap '[ [ length _ random* ] keep nth ] if-empty ;

M: assoc random* [ >alist ] dip random* ;

M: hashtable random*
    [ dup assoc-size [ drop f ] ] dip '[
        [ 0 ] [ array>> ] [ _ random* ] tri* 1 + [
            [ 2dup array-nth tombstone? [ 2 + ] 2dip ] loop
        ] times [ 2 - ] dip
        [ array-nth ] [ [ 1 + ] dip array-nth ] 2bi 2array
    ] if-zero ;

M: sets:set random* [ members ] dip random* ;

M: hash-set random*
    [ dup cardinality [ drop f ] ] dip '[
        [ 0 ] [ array>> ] [ _ random* ] tri* 1 + [
            [ 2dup array-nth tombstone? [ 1 + ] 2dip ] loop
        ] times [ 1 - ] dip array-nth
    ] if-zero ;

: randomize-n-last ( seq n -- seq )
    [ dup length dup ] dip - 1 max '[ dup _ > ]
    random-generator get '[
        [ _ random* ] [ 1 - ] bi
        [ pick exchange-unsafe ] keep
    ] while drop ;

: randomize ( seq -- randomized )
    dup length randomize-n-last ;

ERROR: too-many-samples seq n ;

: sample ( seq n -- seq' )
    2dup [ length ] dip < [ too-many-samples ] when
    [ [ length <iota> >array ] dip [ randomize-n-last ] keep tail-slice* ]
    [ drop ] 2bi nths-unsafe ;

: delete-random ( seq -- elt )
    [ length random ] keep [ nth ] 2keep remove-nth! drop ;

: with-random ( rnd quot -- )
    random-generator swap with-variable ; inline

: with-system-random ( quot -- )
    system-random-generator get swap with-random ; inline

: with-secure-random ( quot -- )
    secure-random-generator get swap with-random ; inline

<PRIVATE

: (uniform-random-float) ( min max rnd -- n )
    [ random-32* ] keep random-32* [ >float ] bi@
    2.0 32 ^ * +
    [ over - 2.0 -64 ^ * ] dip
    * + ; inline

PRIVATE>

: uniform-random-float ( min max -- n )
    random-generator get (uniform-random-float) ; inline

M: float random*
    [ f ] swap '[ 0.0 _ (uniform-random-float) ] if-zero ; inline

<PRIVATE

: random-unit* ( rnd -- n )
    [ 0.0 1.0 ] dip (uniform-random-float) ; inline

PRIVATE>

: random-unit ( -- n )
    random-generator get random-unit* ; inline

: random-units ( length -- sequence )
    random-generator get '[ _ random-unit* ] replicate ;

<PRIVATE

: (cos-random-float) ( -- n )
    0. 2pi uniform-random-float cos ;

: (log-sqrt-random-float) ( -- n )
    random-unit log -2. * sqrt ;

PRIVATE>

: normal-random-float ( mean sigma -- n )
    (cos-random-float) (log-sqrt-random-float) * * + ;

: lognormal-random-float ( mean sigma -- n )
    normal-random-float e^ ;

: exponential-random-float ( lambda -- n )
    random-unit log neg swap / ;

: weibull-random-float ( alpha beta -- n )
    [
        [ random-unit log neg ] dip
        1. swap / ^
    ] dip * ;

: pareto-random-float ( k alpha -- n )
    [ random-unit ] dip recip ^ /f ;

<PRIVATE

:: (gamma-random-float>1) ( alpha beta -- n )
    ! Uses R.C.H. Cheng, "The generation of Gamma
    ! variables with non-integral shape parameters",
    ! Applied Statistics, (1977), 26, No. 1, p71-74
    random-generator get :> rnd
    2. alpha * 1 - sqrt  :> ainv
    alpha 4. log -       :> bbb
    alpha ainv +         :> ccc

    0 :> r! 0 :> z! 0 :> result! ! initialize locals
    [
        r {
            [ 1. 4.5 log + + z 4.5 * - 0 >= ]
            [ z log >= ]
        } 1|| not
    ] [
        rnd random-unit* :> u1
        rnd random-unit* :> u2

        u1 1. u1 - / log ainv / :> v
        alpha v e^ *            :> x
        u1 sq u2 *              z!
        bbb ccc v * + x -       r!

        x beta *                result!
    ] do while result ;

: (gamma-random-float=1) ( alpha beta -- n )
    nip random-unit log neg * ;

:: (gamma-random-float<1) ( alpha beta -- n )
    ! Uses ALGORITHM GS of Statistical Computing - Kennedy & Gentle
    random-generator get :> rnd
    alpha e + e / :> b

    0 :> x! 0 :> p! ! initialize locals
    [
        p 1.0 > [
            rnd random-unit* x alpha 1 - ^ >
        ] [
            rnd random-unit* x neg e^ >
        ] if
    ] [
        rnd random-unit* b * p!
        p 1.0 <= [
            p 1. alpha / ^
        ] [
            b p - alpha / log neg
        ] if x!
    ] do while x beta * ;

PRIVATE>

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
    random-generator get :> rnd
    kappa 1e-6 <= [
        2pi rnd random-unit* *
    ] [
        4. kappa sq * 1. + sqrt 1. + :> a
        a 2. a * sqrt - 2. kappa * / :> b
        b sq 1. + 2. b * /           :> r

        0 :> c! 0 :> _f! ! initialize locals
        [
            rnd random-unit* {
                [ 2. c - c * < ] [ 1. c - e^ c * <= ]
            } 1|| not
        ] [
            rnd random-unit* pi * cos :> z
            r z * 1. + r z + /   _f!
            r _f - kappa *       c!
        ] do while

        mu 2pi mod _f cos
        rnd random-unit* 0.5 > [ + ] [ - ] if
    ] if ;

<PRIVATE

:: (triangular-random-float) ( low high mode -- n )
    mode low - high low - / :> c!
    random-unit :> u!
    high low
    u c > [ 1. u - u! 1. c - c! swap ] when
    [ - u c * sqrt * ] keep + ;

PRIVATE>

: triangular-random-float ( low high -- n )
    2dup + 2 /f (triangular-random-float) ;

: laplace-random-float ( mean scale -- n )
    random-unit dup 0.5 <
    [ 2 * log ] [ 1 swap - 2 * log neg ] if * + ;

: cauchy-random-float ( median scale -- n )
    random-unit 0.5 - pi * tan * + ;

: chi-square-random-float ( dof -- n )
    [ 0.5 ] dip 2 * gamma-random-float ;

: student-t-random-float ( dof -- n )
    [ 0 1 normal-random-float ] dip
    [ chi-square-random-float ] [ / ] bi sqrt / ;

: inv-gamma-random-float ( shape scale -- n )
    recip gamma-random-float recip ;

: rayleigh-random-float ( mode -- n )
    random-unit log -2 * sqrt * ;

: gumbel-random-float ( loc scale -- n )
    random-unit log neg log * - ;

: logistic-random-float ( loc scale -- n )
    random-unit dup 1 swap - / log * + ;

: power-random-float ( alpha -- n )
    [ random-unit log e^ 1 swap - ] dip recip ^ ;

! Box-Muller
: poisson-random-float ( mean -- n )
    [ -1 0 ] dip [ 2dup < ] random-generator get '[
        [ 1 + ] 2dip [ _ random-unit* log neg + ] dip
    ] while 2drop ;

:: binomial-random ( n p -- x )
    n assert-non-negative drop
    p 0.0 1.0 between? [
        {
            { [ p 0.0 = ] [ 0 ] }
            { [ p 1.0 = ] [ n ] }
            { [ n 1 = ] [ random-unit p < 1 0 ? ] }
            { [ p 0.5 > ] [ n dup 1.0 p - binomial-random - ] }
            { [ n p * 10.0 < ] [
                ! BG: Geometric method by Devroye with running time of O(n*p).
                ! https://dl.acm.org/doi/pdf/10.1145/42372.42381
                1.0 p - log :> c
                0 0 random-generator get '[
                    _ random-unit* log c /i 1 + +
                    dup n <= dup [ [ 1 + ] 2dip ] when
                ] loop drop
            ] }
            [
                ! BTRS: Transformed rejection with squeeze method by Wolfgang Hörmann
                ! https://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.47.8407&rep=rep1&type=pdf
                n p * 10.0 >= p 0.5 <= and t assert=
                random-generator get :> rnd

                n p * 1.0 p - * sqrt :> spq
                1.15 2.53 spq * + :> b
                -0.0873 0.0248 b * + 0.01 p * + :> a
                n p * 0.5 + :> c
                0.92 4.2 b / - :> vr

                2.83 5.1 b / + spq * :> alpha
                p 1.0 p - / log :> lpq
                n 1 + p * floor :> m
                m 1 + lgamma n m - 1 + lgamma + :> h

                f [
                    rnd random-unit* 0.5 - :> u
                    rnd random-unit* :> v
                    0.5 u abs - :> us
                    drop 2.0 a us / * b + u * c + floor >integer dup :> k
                    k 0 n between? [
                        { [ us 0.07 >= ] [ v vr <= ] } 0&& [ f ] [
                            alpha a us sq / b + / v * log
                            h k 1 + lgamma - n k - 1 +
                            lgamma - k m - lpq * + >
                        ] if
                    ] [ t ] if
                ] loop
            ]
        } cond
    ] [
        "p must be in the range 0.0 <= p <= 1.0" throw
    ] if ;

{
    { [ os windows? ] [ "random.windows" require ] }
    { [ os unix? ] [ "random.unix" require ] }
} cond

"random.mersenne-twister" require
