! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.data arrays assocs byte-arrays
byte-vectors combinators combinators.short-circuit fry
hashtables hashtables.private hash-sets hints io.backend
io.binary kernel locals math math.bitwise math.constants
math.functions math.order math.ranges namespaces sequences
sequences.private sets summary system typed vocabs ;
QUALIFIED-WITH: alien.c-types c
QUALIFIED-WITH: sets sets
IN: random

SYMBOL: system-random-generator
SYMBOL: secure-random-generator
SYMBOL: random-generator

GENERIC#: seed-random 1 ( obj seed -- obj )
GENERIC: random-32* ( obj -- n )
GENERIC: random-bytes* ( n obj -- byte-array )

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

M: f random-bytes* ( n obj -- * ) no-random-number-generator ;

M: f random-32* ( obj -- * ) no-random-number-generator ;

: random-32 ( -- n )
    random-generator get random-32* ;

: random-bytes ( n -- byte-array )
    random-generator get random-bytes* ;

<PRIVATE

:: (random-bits) ( numbits obj -- n )
    numbits 32 > [
        obj random-32* numbits 32 - [ dup 32 > ] [
            [ 32 shift obj random-32* + ] [ 32 - ] bi*
        ] while [
            [ shift ] keep obj random-32* swap bits +
        ] unless-zero
    ] [
        obj random-32* numbits bits
    ] if ; inline

PRIVATE>

: random-bits ( numbits -- n )
    random-generator get (random-bits) ;

: random-bits* ( numbits -- n )
    1 - [ random-bits ] keep set-bit ;

<PRIVATE

: next-power-of-2-bits ( m -- numbits )
    dup 2 <= [ drop 1 ] [ 1 - log2 1 + ] if ; inline

:: random-integer-loop ( m obj -- n )
    obj random-32* 32 m next-power-of-2-bits 32 - [ dup 0 > ] [
        [ 32 shift obj random-32* + ] [ 32 + ] [ 32 - ] tri*
    ] while drop [ m * ] [ neg shift ] bi* ; inline

GENERIC#: (random-integer) 1 ( m obj -- n )
M: fixnum (random-integer) ( m obj -- n ) random-integer-loop ;
M: bignum (random-integer) ( m obj -- n ) random-integer-loop ;

: random-integer ( m -- n )
    random-generator get (random-integer) ;

PRIVATE>

GENERIC: random ( obj -- elt )

M: integer random
    [ f ] [ random-integer ] if-zero ;

M: sequence random
    [ f ] [
        [ length random-integer ] keep nth
    ] if-empty ;

M: assoc random >alist random ;

M: hashtable random
    dup assoc-size [ drop f ] [
        [ 0 ] [ array>> ] [ random ] tri* 1 + [
            [ 2dup array-nth tombstone? [ 2 + ] 2dip ] loop
        ] times [ 2 - ] dip
        [ array-nth ] [ [ 1 + ] dip array-nth ] 2bi 2array
    ] if-zero ;

M: sets:set random members random ;

M: hash-set random
    dup cardinality [ drop f ] [
        [ 0 ] [ array>> ] [ random ] tri* 1 + [
            [ 2dup array-nth tombstone? [ 1 + ] 2dip ] loop
        ] times [ 1 - ] dip array-nth
    ] if-zero ;

: randomize-n-last ( seq n -- seq )
    [ dup length dup ] dip - 1 max '[ dup _ > ]
    random-generator get '[
        [ _ (random-integer) ] [ 1 - ] bi
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
    [ length random-integer ] keep
    [ nth ] 2keep remove-nth! drop ;

: with-random ( obj quot -- )
    random-generator swap with-variable ; inline

: with-system-random ( quot -- )
    system-random-generator get swap with-random ; inline

: with-secure-random ( quot -- )
    secure-random-generator get swap with-random ; inline

<PRIVATE

: (uniform-random-float) ( min max obj -- n )
    [ random-32* ] keep random-32* [ >float ] bi@
    2.0 32 ^ * +
    [ over - 2.0 -64 ^ * ] dip
    * + ; inline

PRIVATE>

: uniform-random-float ( min max -- n )
    random-generator get (uniform-random-float) ; inline

M: float random [ f ] [ 0.0 swap uniform-random-float ] if-zero ;

<PRIVATE

: (random-unit) ( obj -- n )
    [ 0.0 1.0 ] dip (uniform-random-float) ; inline

PRIVATE>

: random-unit ( -- n )
    random-generator get (random-unit) ; inline

: random-units ( length -- sequence )
    random-generator get '[ _ (random-unit) ] replicate ;

: random-integers ( length n -- sequence )
    random-generator get '[ _ _ (random-integer) ] replicate ;

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
        rnd (random-unit) :> u1
        rnd (random-unit) :> u2

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
            rnd (random-unit) x alpha 1 - ^ >
        ] [
            rnd (random-unit) x neg e^ >
        ] if
    ] [
        rnd (random-unit) b * p!
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
        2pi rnd (random-unit) *
    ] [
        4. kappa sq * 1. + sqrt 1. + :> a
        a 2. a * sqrt - 2. kappa * / :> b
        b sq 1. + 2. b * /           :> r

        0 :> c! 0 :> _f! ! initialize locals
        [
            rnd (random-unit) {
                [ 2. c - c * < ] [ 1. c - e^ c * <= ]
            } 1|| not
        ] [
            rnd (random-unit) pi * cos :> z
            r z * 1. + r z + /   _f!
            r _f - kappa *       c!
        ] do while

        mu 2pi mod _f cos
        rnd (random-unit) 0.5 > [ + ] [ - ] if
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
        [ 1 + ] 2dip [ _ (random-unit) log neg + ] dip
    ] while 2drop ;

{
    { [ os windows? ] [ "random.windows" require ] }
    { [ os unix? ] [ "random.unix" require ] }
} cond

"random.mersenne-twister" require
