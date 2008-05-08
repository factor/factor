! Copyright (C) 2007 Samuel Tardieu.
! See http://factorcode.org/license.txt for BSD license.
USING: combinators kernel lazy-lists math math.functions math.miller-rabin
       math.order math.primes.list math.ranges sequences sorting ;
IN: math.primes

<PRIVATE

: find-prime-miller-rabin ( n -- p )
  dup miller-rabin [ 2 + find-prime-miller-rabin ] unless ; foldable

PRIVATE>

: next-prime ( n -- p )
  dup 999983 < [
    primes-under-million [ [ <=> ] binsearch 1+ ] keep nth
  ] [
    next-odd find-prime-miller-rabin
  ] if ; foldable

: prime? ( n -- ? )
  dup 1000000 < [
    dup primes-under-million [ <=> ] binsearch* =
  ] [
    miller-rabin
  ] if ; foldable

: lprimes ( -- list )
  0 primes-under-million seq>list
  1000003 [ 2 + find-prime-miller-rabin ] lfrom-by
  lappend ;

: lprimes-from ( n -- list )
  dup 3 < [ drop lprimes ] [  1- next-prime [ next-prime ] lfrom-by ] if ;

: primes-upto ( n -- seq )
  {
    { [ dup 2 < ] [ drop { } ] }
    { [ dup 1000003 < ]
      [ primes-under-million [ [ <=> ] binsearch 1+ 0 swap ] keep <slice> ] }
    [ primes-under-million 1000003 lprimes-from
        rot [ <= ] curry lwhile list>array append ]
  } cond ; foldable

: primes-between ( low high -- seq )
  primes-upto
  [ 1- next-prime ] dip
  [ [ <=> ] binsearch ] keep [ length ] keep <slice> ; foldable

: coprime? ( a b -- ? ) gcd nip 1 = ; foldable
