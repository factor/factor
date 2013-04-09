! Copyright (C) 2013 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: combinators kernel math math.functions math.ranges
memoize sequences ;

IN: math.factorials

MEMO: factorial ( n -- n! )
    dup 1 > [ [1,b] product ] [ drop 1 ] if ;

ALIAS: n! factorial

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
            [ (a,b] product ] dip [ recip ] when
        ]
    } cond ;

: rising-factorial ( x n -- x(n) )
    {
        { 1 [ ] }
        { 0 [ drop 0 ] }
        [
            dup 0 < [ neg [ + ] keep t ] [ f ] if
            [ dupd + [a,b) product ] dip
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
            [ dupd - swap (a,b] product ] dip
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
