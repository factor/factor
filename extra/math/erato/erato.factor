! Copyright (c) 2007 Samuel Tardieu.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors bit-arrays fry kernel lists.lazy math math.functions
    math.primes.list math.ranges sequences ;
IN: math.erato

<PRIVATE

TUPLE: erato limit bits latest ;

: ind ( n -- i )
    2/ 1- ; inline

: is-prime ( n limit -- bool )
    [ ind ] [ bits>> ] bi* nth ; inline

: indices ( n erato -- range )
    limit>> ind over 3 * ind swap rot <range> ;

: mark-multiples ( n erato -- )
    2dup [ sq ] [ limit>> ] bi* <= [
        [ indices ] keep bits>> '[ _ f -rot set-nth ] each
    ] [ 2drop ] if ;

: <erato> ( n -- erato )
    dup ind 1+ <bit-array> dup set-bits 1 erato boa ;

: next-prime ( erato -- prime/f )
    [ 2 + ] change-latest [ latest>> ] keep
    2dup limit>> <= [
        2dup is-prime [ dupd mark-multiples ] [ nip next-prime ] if
    ] [
        2drop f
    ] if ;

PRIVATE>

: lerato ( n -- lazy-list )
    dup 1000003 < [
        0 primes-under-million seq>list swap '[ _ <= ] lwhile
    ] [
        <erato> 2 [ drop next-prime ] with lfrom-by [ ] lwhile
    ] if ;
