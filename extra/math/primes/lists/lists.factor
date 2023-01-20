! Copyright (C) 2007-2009 Samuel Tardieu.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel lists.lazy math math.primes ;
IN: math.primes.lists

: lprimes ( -- list ) 2 [ next-prime ] lfrom-by ;

: lprimes-from ( n -- list )
    dup 3 < [ drop lprimes ] [ 1 - next-prime [ next-prime ] lfrom-by ] if ;
