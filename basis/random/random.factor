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

:: random-bits* ( numbits rnd -- n )
    numbits 32 > [
        rnd random-32* numbits 32 - [ dup 32 > ] [
            [ 32 shift rnd random-32* + ] [ 32 - ] bi*
        ] while [
            [ shift ] keep rnd random-32* swap bits +
        ] unless-zero
    ] [
        rnd random-32* numbits bits
    ] if ;

: random-bits ( numbits -- n )
    random-generator get random-bits* ;

: random-bits-exact* ( numbits rnd -- n )
    [ 1 - ] dip '[ _ random-bits* ] keep set-bit ;

: random-bits-exact ( numbits -- n )
    random-generator get random-bits-exact* ;

GENERIC#: random* 1 ( obj rnd -- elt )

: random ( obj -- elt )
    random-generator get random* ;

: randoms-as ( length obj exemplar -- seq )
    [ random-generator get '[ _ _ random* ] ] dip replicate-as ; inline

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

: uniform-random* ( min max rnd -- n )
    [ random-32* ] keep random-32* [ >float ] bi@
    2.0 32 ^ * + [ over - 2.0 -64 ^ * ] dip * + ; inline

: uniform-random ( min max -- n )
    random-generator get uniform-random* ;

TUPLE: uniform-distribution min max ;
C: <uniform-distribution> uniform-distribution
M: uniform-distribution random*
    [ [ min>> ] [ max>> ] bi ] dip uniform-random* ;

M: float random*
    [ f ] swap '[ 0.0 _ uniform-random* ] if-zero ; inline

: random-unit* ( rnd -- n )
    [ 0.0 1.0 ] dip uniform-random* ; inline

: random-unit ( -- n )
    random-generator get random-unit* ; inline

: random-units ( length -- sequence )
    random-generator get '[ _ random-unit* ] replicate ;

:: normal-random* ( mean sigma rnd -- n )
    0.0 2pi rnd uniform-random* cos
    rnd random-unit* log -2.0 * sqrt * sigma * mean + ;

: normal-random ( mean sigma -- n )
    random-generator get normal-random* ;

TUPLE: normal-distribution mean sigma ;
C: <normal-distribution> normal-distribution
M: normal-distribution random*
    [ [ mean>> ] [ sigma>> ] bi ] dip normal-random* ;

: lognormal-random* ( mean sigma rnd -- n )
    normal-random* e^ ;

: lognormal-random ( mean sigma -- n )
    random-generator get lognormal-random* ;

TUPLE: lognormal-distribution < normal-distribution ;
C: <lognormal-distribution> lognormal-distribution
M: lognormal-distribution random* call-next-method e^ ;

: exponential-random* ( lambda rnd -- n )
    random-unit* log neg swap / ;

: exponential-random ( lambda -- n )
    random-generator get exponential-random* ;

TUPLE: exponential-distribution lambda ;
C: <exponential-distribution> exponential-distribution
M: exponential-distribution random*
    [ lambda>> ] dip exponential-random* ;

:: weibull-random* ( alpha beta rnd -- n )
    rnd random-unit* log neg alpha recip ^ beta * ;

: weibull-random ( alpha beta -- n )
    random-generator get weibull-random* ;

TUPLE: weibull-distribution alpha beta ;
C: <weibull-distribution> weibull-distribution
M: weibull-distribution random*
    [ [ alpha>> ] [ beta>> ] bi ] dip weibull-random* ;

:: pareto-random* ( k alpha rnd -- n )
    k rnd random-unit* alpha recip ^ /f ;

: pareto-random ( k alpha -- n )
    random-generator get pareto-random* ;

TUPLE: pareto-distribution k alpha ;
C: <pareto-distribution> pareto-distribution
M: pareto-distribution random*
    [ [ k>> ] [ alpha>> ] bi ] dip pareto-random* ;

<PRIVATE

:: (gamma-random>1) ( alpha beta rnd -- n )
    ! Uses R.C.H. Cheng, "The generation of Gamma
    ! variables with non-integral shape parameters",
    ! Applied Statistics, (1977), 26, No. 1, p71-74
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

: (gamma-random=1) ( alpha beta rnd -- n )
    random-unit* log neg * nip ;

:: (gamma-random<1) ( alpha beta rnd -- n )
    ! Uses ALGORITHM GS of Statistical Computing - Kennedy & Gentle
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

: gamma-random* ( alpha beta rnd -- n )
    {
        { [ pick 1 > ] [ (gamma-random>1) ] }
        { [ pick 1 = ] [ (gamma-random=1) ] }
        [ (gamma-random<1) ]
    } cond ;

: gamma-random ( alpha beta -- n )
    random-generator get gamma-random* ;

TUPLE: gamma-distribution alpha beta ;
C: <gamma-distribution> gamma-distribution
M: gamma-distribution random*
    [ [ alpha>> ] [ beta>> ] bi ] dip gamma-random* ;

:: beta-random* ( alpha beta rnd -- n )
    alpha 1.0 rnd gamma-random* [ 0 ] [
        beta 1.0 rnd gamma-random* dupd + /
    ] if-zero ;

: beta-random ( alpha beta -- n )
    random-generator get beta-random* ;

TUPLE: beta-distribution alpha beta ;
C: <beta-distribution> beta-distribution
M: beta-distribution random*
    [ [ alpha>> ] [ beta>> ] bi ] dip beta-random* ;

:: von-mises-random* ( mu kappa rnd -- n )
    ! Based upon an algorithm published in: Fisher, N.I.,
    ! "Statistical Analysis of Circular Data", Cambridge
    ! University Press, 1993.
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

: von-mises-random ( mu kappa -- n )
    random-generator get von-mises-random* ;

TUPLE: von-mises-distribution mu kappa ;
C: <von-mises-distribution> von-mises-distribution
M: von-mises-distribution random*
    [ [ mu>> ] [ kappa>> ] bi ] dip von-mises-random* ;

:: triangular-random* ( low high rnd -- n )
    low high + 2 /f :> mode
    mode low - high low - / :> c!
    rnd random-unit* :> u!
    high low
    u c > [ 1. u - u! 1. c - c! swap ] when
    [ - u c * sqrt * ] keep + ;

: triangular-random ( low high -- n )
    random-generator get triangular-random* ;

TUPLE: triangular-distribution low high ;
C: <triangular-distribution> triangular-distribution
M: triangular-distribution random*
    [ [ low>> ] [ high>> ] bi ] dip triangular-random* ;

: laplace-random* ( mean scale rnd -- n )
    random-unit* dup 0.5 <
    [ 2 * log ] [ 1 swap - 2 * log neg ] if * + ;

: laplace-random ( mean scale -- n )
    random-generator get laplace-random* ;

TUPLE: laplace-distribution mean scale ;
C: <laplace-distribution> laplace-distribution
M: laplace-distribution random*
    [ [ mean>> ] [ scale>> ] bi ] dip laplace-random* ;

: cauchy-random* ( median scale rnd -- n )
    random-unit* 0.5 - pi * tan * + ;

: cauchy-random ( median scale -- n )
    random-generator get cauchy-random* ;

TUPLE: cauchy-distribution median scale ;
C: <cauchy-distribution> cauchy-distribution
M: cauchy-distribution random*
    [ [ median>> ] [ scale>> ] bi ] dip cauchy-random* ;

:: chi-square-random* ( dof rnd -- n )
    dof 2.0 / 2.0 rnd gamma-random* ;

: chi-square-random ( dof -- n )
    random-generator get chi-square-random* ;

TUPLE: chi-square-distribution dof ;
C: <chi-square-distribution> chi-square-distribution
M: chi-square-distribution random*
    [ dof>> ] dip chi-square-random* ;

:: student-t-random* ( dof rnd -- n )
    0 1 rnd normal-random*
    dof rnd chi-square-random*
    dof / sqrt / ;

: student-t-random ( dof -- n )
    random-generator get student-t-random* ;

TUPLE: student-t-distribution dof ;
C: <student-t-distribution> student-t-distribution
M: student-t-distribution random*
    [ dof>> ] dip student-t-random* ;

:: inv-gamma-random* ( shape scale rnd -- n )
    shape scale recip rnd gamma-random* recip ;

: inv-gamma-random ( shape scale -- n )
    random-generator get inv-gamma-random* ;

TUPLE: inv-gamma-distribution shape scale ;
C: <inv-gamma-distribution> inv-gamma-distribution
M: inv-gamma-distribution random*
    [ [ shape>> ] [ scale>> ] bi ] dip inv-gamma-random* ;

: rayleigh-random* ( mode rnd -- n )
    random-unit* log -2 * sqrt * ;

: rayleigh-random ( mode -- n )
    random-generator get rayleigh-random* ;

TUPLE: rayleigh-distribution mode ;
C: <rayleigh-distribution> rayleigh-distribution
M: rayleigh-distribution random*
    [ mode>> ] dip rayleigh-random* ;

: gumbel-random* ( loc scale rnd -- n )
    random-unit* log neg log * - ;

: gumbel-random ( loc scale -- n )
    random-generator get gumbel-random* ;

TUPLE: gumbel-distribution loc scale ;
C: <gumbel-distribution> gumbel-distribution
M: gumbel-distribution random*
    [ [ loc>> ] [ scale>> ] bi ] dip gumbel-random* ;

: logistic-random* ( loc scale rnd -- n )
    random-unit* dup 1 swap - / log * + ;

: logistic-random ( loc scale -- n )
    random-generator get logistic-random* ;

TUPLE: logistic-distribution loc scale ;
C: <logistic-distribution> logistic-distribution
M: logistic-distribution random*
    [ [ loc>> ] [ scale>> ] bi ] dip logistic-random* ;

: power-random* ( alpha rnd -- n )
    random-unit* log e^ 1 swap - swap recip ^ ;

: power-random ( alpha -- n )
    random-generator get power-random* ;

TUPLE: power-distribution alpha ;
C: <power-distribution> power-distribution
M: power-distribution random*
    [ alpha>> ] dip power-random* ;

:: poisson-random* ( mean rnd -- n )
    ! Box-Muller
    -1 0 mean [ 2dup < ] [
        [ 1 + ] 2dip [ rnd random-unit* log neg + ] dip
    ] while 2drop ;

: poisson-random ( mean -- n )
    random-generator get poisson-random* ;

TUPLE: poisson-distribution mean ;
C: <poisson-distribution> poisson-distribution
M: poisson-distribution random*
    [ mean>> ] dip poisson-random* ;

:: binomial-random* ( n p rnd -- elt )
    n assert-non-negative drop {
        { [ p 0.0 1.0 between? not ] [ "p must be in the range 0.0 <= p <= 1.0" throw ] }
        { [ p 0.0 = ] [ 0 ] }
        { [ p 1.0 = ] [ n ] }
        { [ n 1 = ] [ rnd random-unit* p < 1 0 ? ] }
        { [ p 0.5 > ] [ n dup 1.0 p - rnd binomial-random* - ] }
        { [ n p * 10.0 < ] [
            ! BG: Geometric method by Devroye with running time of O(n*p).
            ! https://dl.acm.org/doi/pdf/10.1145/42372.42381
            1.0 p - log :> c
            0 0 [
                rnd random-unit* log c /i 1 + +
                dup n <= dup [ [ 1 + ] 2dip ] when
            ] loop drop
        ] }
        [
            ! BTRS: Transformed rejection with squeeze method by Wolfgang Hörmann
            ! https://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.47.8407&rep=rep1&type=pdf
            n p * 10.0 >= p 0.5 <= and t assert=

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
    } cond ;

: binomial-random ( n p -- x )
    random-generator get binomial-random* ;

TUPLE: binomial-distribution n p ;
C: <binomial-distribution> binomial-distribution
M: binomial-distribution random*
    [ [ n>> ] [ p>> ] bi ] dip binomial-random* ;

:: zipf-random* ( a rnd -- n )
    a 1.0 - :> am1 2.0 am1 ^ :> b
    1.0 rnd random-unit* - :> U
    rnd random-unit* :> V
    U am1 recip neg ^ floor :> X
    1.0 X recip + am1 ^ :> T
    V X * T 1.0 - * b 1.0 - / T b / <= [
        X
    ] [
        a rnd zipf-random*
    ] if ;

: zipf-random ( a -- n )
    random-generator get zipf-random* ;

TUPLE: zipf-distribution a ;
C: <zipf-distribution> zipf-distribution
M: zipf-distribution random*
    [ a>> ] dip zipf-random* ;

:: wald-random* ( mean scale rnd -- n )
    mean scale 2 * / :> mu_2l
    0 1 rnd normal-random* sq mean * :> Y
    mean Y sq 4 scale * Y * + sqrt Y swap - mu_2l * + :> X
    rnd random-unit* :> U
    U mean dup X + / <= [
        X
    ] [
        mean sq X /
    ] if ;

: wald-random ( mean scale -- n )
    random-generator get wald-random* ;

TUPLE: wald-distribution mean scale ;
C: <wald-distribution> wald-distribution
M: wald-distribution random*
    [ [ mean>> ] [ scale>> ] bi ] dip wald-random* ;

:: geometric-random* ( p rnd -- n )
    p 0.333333333333333333333333 >= [
        1.0 p - :> q
        rnd random-unit* :> U
        1 p p [ U over > ] [
            [ 1 + ] [ q * ] [ dupd + ] tri*
        ] while 2drop
    ] [
        1.0 rnd random-unit* - log 1.0 p - log / ceiling
        >integer
    ] if ;

: geometric-random ( p -- n )
    random-generator get geometric-random* ;

TUPLE: geometric-distribution p ;
C: <geometric-distribution> geometric-distribution
M: geometric-distribution random*
    [ p>> ] dip geometric-random* ;

:: logseries-random* ( p rnd -- n )
    1.0 p - log :> r
    f [
        drop
        rnd random-unit* :> V
        V p >= [ 1 ] [
            rnd random-unit* :> U
            1.0 r U * e^ - :> q
            V 0 > V q sq <= and [
                1 V log q log / + floor >integer
                [ f ] when-zero
            ] [ f ] if [ V q >= 1 2 ? ] unless*
        ] if dup not
    ] loop ;

: logseries-random ( p -- n )
    random-generator get logseries-random* ;

TUPLE: logseries-distribution p ;
C: <logseries-distribution> logseries-distribution
M: logseries-distribution random*
    [ p>> ] dip logseries-random* ;

:: f-random* ( dof-num dof-den rnd -- n )
    dof-num rnd chi-square-random* dof-den *
    dof-den rnd chi-square-random* dof-num * / ;

: f-random ( df-num df-den -- n )
    random-generator get f-random* ;

TUPLE: f-distribution dof-num dof-den ;
C: <f-distribution> f-distribution
M: f-distribution random*
    [ [ dof-num>> ] [ dof-den>> ] bi ] dip f-random* ;

: bernoulli-random* ( p rnd -- n )
    [ 1 ] 2dip binomial-random* ;

: bernoulli-random ( p -- n )
    random-generator get bernoulli-random* ;

TUPLE: bernoulli-distribution p ;
C: <bernoulli-distribution> bernoulli-distribution
M: bernoulli-distribution random*
    [ p>> ] dip bernoulli-random* ;

{
    { [ os windows? ] [ "random.windows" require ] }
    { [ os unix? ] [ "random.unix" require ] }
} cond

"random.mersenne-twister" require
