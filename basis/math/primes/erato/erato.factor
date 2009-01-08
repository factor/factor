! Copyright (C) 2009 Samuel Tardieu.
! See http://factorcode.org/license.txt for BSD license.
USING: bit-arrays kernel math math.functions math.ranges sequences ;
IN: math.primes.erato

: >index ( n -- i )
    3 - 2 /i ; inline

: index> ( i -- n )
    2 * 3 + ; inline

: mark-multiples ( i arr -- )
    [ index> [ sq >index ] keep ] dip
    [ length 1 - swap <range> f swap ] keep
    [ set-nth ] curry with each ;

: maybe-mark-multiples ( i arr -- )
    2dup nth [ mark-multiples ] [ 2drop ] if ;

: init-sieve ( n -- arr )
    >index 1 + <bit-array> dup set-bits ;

: sieve ( n -- arr )
    [ init-sieve ] [ sqrt >index [0,b] ] bi
    over [ maybe-mark-multiples ] curry each ; foldable
