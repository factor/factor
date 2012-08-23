! Copyright (C) 2009 Samuel Tardieu.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays byte-arrays kernel math math.bitwise math.functions math.order
math.ranges sequences sequences.private ;
IN: math.primes.erato

<PRIVATE

CONSTANT: masks B{ 0 128 0 0 0 0 0 64 0 0 0 32 0 16 0 0 0 8 0 4 0 0 0 2 0 0 0 0 0 1 }

: bit-pos ( n -- byte/f mask/f )
    30 /mod masks nth-unsafe [ drop f f ] when-zero ; inline

: marked-unsafe? ( n arr -- ? )
    [ bit-pos ] dip swap
    [ [ nth-unsafe ] [ bitand zero? not ] bi* ] [ 2drop f ] if* ; inline

: unmark ( n arr -- )
    [ bit-pos swap ] dip
    over [ [ swap unmask ] change-nth-unsafe ] [ 3drop ] if ; inline

: upper-bound ( arr -- n ) length 30 * 1 - ; inline

: unmark-multiples ( i arr -- )
    2dup marked-unsafe? [
        [ [ dup sq ] [ upper-bound ] bi* rot <range> ] keep
        [ unmark ] curry each
    ] [
        2drop
    ] if ; inline

: init-sieve ( n -- arr ) 30 /i 1 + 255 <array> >byte-array ; inline

PRIVATE>

: sieve ( n -- arr )
    init-sieve [ 2 swap upper-bound sqrt [a,b] ] keep
    [ [ unmark-multiples ] curry each ] keep ;

: marked-prime? ( n arr -- ? )
    2dup upper-bound 2 swap between? [ bounds-error ] unless
    over { 2 3 5 } member? [ 2drop t ] [ marked-unsafe? ] if ;
