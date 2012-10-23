! Copyright (C) 2009 Samuel Tardieu.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays byte-arrays kernel math math.bitwise math.functions math.order
math.ranges sequences sequences.private ;
IN: math.primes.erato

<PRIVATE

CONSTANT: masks
{ f 128 f f f f f 64 f f f 32 f 16 f f f 8 f 4 f f f 2 f f f f f 1 }

: bit-pos ( n -- byte mask/f )
    30 /mod masks nth-unsafe ; inline

: marked-unsafe? ( n arr -- ? )
    [ bit-pos ] dip swap
    [ [ nth-unsafe ] [ bitand zero? not ] bi* ] [ 2drop f ] if* ; inline

: unmark ( n arr -- )
    [ bit-pos swap ] dip
    pick [ [ swap unmask ] change-nth-unsafe ] [ 3drop ] if ; inline

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
