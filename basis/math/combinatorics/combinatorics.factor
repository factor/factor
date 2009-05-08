! Copyright (c) 2007-2009 Slava Pestov, Doug Coleman, Aaron Schaefer.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs binary-search fry kernel locals math math.order
    math.ranges mirrors namespaces sequences sorting ;
IN: math.combinatorics

<PRIVATE

: possible? ( n m -- ? )
    0 rot between? ; inline

: twiddle ( n k -- n k )
    2dup - dupd > [ dupd - ] when ; inline

PRIVATE>

: factorial ( n -- n! )
    1 [ 1 + * ] reduce ;

: nPk ( n k -- nPk )
    2dup possible? [ dupd - [a,b) product ] [ 2drop 0 ] if ;

: nCk ( n k -- nCk )
    twiddle [ nPk ] keep factorial / ;


! Factoradic-based permutation methodology

<PRIVATE

: factoradic ( n -- factoradic )
    0 [ over 0 > ] [ 1 + [ /mod ] keep swap ] produce reverse 2nip ;

: (>permutation) ( seq n -- seq )
    [ '[ _ dupd >= [ 1 + ] when ] map ] keep prefix ;

: >permutation ( factoradic -- permutation )
    reverse 1 cut [ (>permutation) ] each ;

: permutation-indices ( n seq -- permutation )
    length [ factoradic ] dip 0 pad-head >permutation ;

PRIVATE>

: permutation ( n seq -- seq )
    [ permutation-indices ] keep nths ;

: all-permutations ( seq -- seq )
    [ length factorial ] keep
    '[ _ permutation ] map ;

: each-permutation ( seq quot -- )
    [ [ length factorial ] keep ] dip
    '[ _ permutation @ ] each ; inline

: reduce-permutations ( seq identity quot -- result )
    swapd each-permutation ; inline

: inverse-permutation ( seq -- permutation )
    <enum> >alist sort-values keys ;


! Combinadic-based combination methodology

<PRIVATE

TUPLE: combo
    { seq sequence }
    { k integer } ;

C: <combo> combo

: choose ( combo -- nCk )
    [ seq>> length ] [ k>> ] bi nCk ;

: largest-value ( a b x -- v )
    dup 0 = [
        drop 1 - nip
    ] [
        [ [0,b) ] 2dip '[ _ nCk _ >=< ] search nip
    ] if ;

:: next-values ( a b x -- a' b' x' v )
    a b x largest-value dup :> v  ! a'
    b 1 -                         ! b'
    x v b nCk -                   ! x'
    v ;                           ! v == a'

: dual-index ( m combo -- m' )
    choose 1 - swap - ;

: initial-values ( combo m -- n k m )
    [ [ seq>> length ] [ k>> ] bi ] dip ;

: combinadic ( combo m -- combinadic )
    initial-values [ over 0 > ] [ next-values ] produce
    [ 3drop ] dip ;

: combination-indices ( m combo -- seq )
    [ tuck dual-index combinadic ] keep
    seq>> length 1 - swap [ - ] with map ;

: apply-combination ( m combo -- seq )
    [ combination-indices ] keep seq>> nths ;

PRIVATE>

: combination ( m seq k -- seq )
    <combo> apply-combination ;

: all-combinations ( seq k -- seq )
    <combo> [ choose [0,b) ] keep
    '[ _ apply-combination ] map ;

: each-combination ( seq k quot -- )
    [ <combo> [ choose [0,b) ] keep ] dip
    '[ _ apply-combination @ ] each ; inline

: map-combinations ( seq k quot -- )
    [ <combo> [ choose [0,b) ] keep ] dip
    '[ _ apply-combination @ ] map ; inline

: reduce-combinations ( seq k identity quot -- result )
    [ -rot ] dip each-combination ; inline

