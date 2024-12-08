! Copyright (C) 2013 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: combinators combinators.short-circuit inverse kernel
math math.constants math.functions math.primes ranges sequences ;

IN: math.factorials

MEMO: factorial ( n -- n! )
    dup 1 > [ [1..b] product ] [ drop 1 ] if ;

ALIAS: n! factorial

: factorials ( n -- seq )
    1 swap [0..b] [ dup 1 > [ * ] [ drop ] if dup ] map nip ;

MEMO: double-factorial ( n -- n!! )
    dup [ even? ] [ 0 < ] bi [
        [ drop 1/0. ] [
            2 + -1 swap -2 <range> product recip
        ] if
    ] [
        2 3 ? swap 2 <range> product
    ] if ;

ALIAS: n!! double-factorial

: factorial/ ( n k -- n!/k! )
    {
        { [ dup 1 <= ] [ drop factorial ] }
        { [ over 1 <= ] [ nip factorial recip ] }
        [
            2dup < [ t ] [ swap f ] if
            [ (a..b] product ] dip [ recip ] when
        ]
    } cond ;

: rising-factorial ( x n -- x(n) )
    {
        { 1 [ ] }
        { 0 [ drop 0 ] }
        [
            dup 0 < [ neg [ + ] keep t ] [ f ] if
            [ dupd + [a..b) product ] dip
            [ recip ] when
        ]
    } case ;

ALIAS: pochhammer rising-factorial

: falling-factorial ( x n -- (x)n )
    {
        { 1 [ ] }
        { 0 [ drop 0 ] }
        [
            dup 0 < [ neg [ + ] keep t ] [ f ] if
            [ dupd - swap (a..b] product ] dip
            [ recip ] when
        ]
    } case ;

: factorial-power ( x n h -- (x)n(h) )
    {
        { 1 [ falling-factorial ] }
        { 0 [ ^ ] }
        [
            over 0 < [
                [ [ nip + ] [ swap neg * + ] 3bi ] keep
                <range> product recip
            ] [
                neg [ [ dupd 1 - ] [ * ] bi* + ] keep
                <range> product
            ] if
        ]
    } case ;

: primorial ( n -- p# )
    dup 0 > [ nprimes product ] [ drop 1 ] if ;

: multifactorial ( n k -- n!(k) )
    2dup >= [
        dupd [ - ] keep multifactorial *
    ] [ 2drop 1 ] if ; inline recursive

: quadruple-factorial ( n -- m )
    [ 2 * ] keep factorial/ ;

: super-factorial ( n -- m )
    dup 1 > [
        [1..b] [ factorial ] [ * ] map-reduce
    ] [ drop 1 ] if ;

: hyper-factorial ( n -- m )
    dup 1 > [
        [1..b] [ dup ^ ] [ * ] map-reduce
    ] [ drop 1 ] if ;

: alternating-factorial ( n -- m )
    dup 1 > [
        [ [1..b] ] keep even? '[
            [ factorial ] [ odd? _ = ] bi [ neg ] when
        ] map-sum
    ] [ drop 1 ] if ;

: exponential-factorial ( n -- m )
    dup 1 > [ [1..b] 1 [ swap ^ ] reduce ] [ drop 1 ] if ;

<PRIVATE

: -prime? ( n quot: ( n -- m ) -- ? )
    [ 1 1 [ pick over - 1 <= ] ] dip
    '[ drop [ 1 + ] _ bi ] until nip - abs 1 = ; inline

PRIVATE>

: factorial-prime? ( n -- ? )
    { [ prime? ] [ [ factorial ] -prime? ] } 1&& ;

: primorial-prime? ( n -- ? )
    { [ prime? ] [ 2 > ] [ [ primorial ] -prime? ] } 1&& ;

: reverse-factorial ( m -- n )
    1 1 [ 2over > ] [ 1 + [ * ] keep ] while [ = ] dip and ;

\ factorial [ reverse-factorial ] define-inverse

: subfactorial ( n -- ? )
    [ 1 ] [ factorial 1 + e /i ] if-zero ;

ALIAS: !n subfactorial
