! Copyright (c) 2012 Anonymous
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays formatting kernel literals math
math.functions math.matrices ranges sequences ;
IN: rosetta-code.pythagorean-triples

! https://rosettacode.org/wiki/Pythagorean_triples

! A Pythagorean triple is defined as three positive integers
! (a,b,c) where a < b < c, and a2 + b2 = c2. They are called
! primitive triples if a,b,c are coprime, that is, if their
! pairwise greatest common divisors gcd(a,b) = gcd(a,c) = gcd(b,c)
! = 1. Because of their relationship through the Pythagorean
! theorem, a, b, and c are coprime if a and b are coprime
! (gcd(a,b) = 1). Each triple forms the length of the sides of a
! right triangle, whose perimeter is P = a + b + c.

! Task

! The task is to determine how many Pythagorean triples there
! are with a perimeter no larger than 100 and the number of these
! that are primitive.

! Extra credit: Deal with large values. Can your program handle
! a max perimeter of 1,000,000? What about 10,000,000?
! 100,000,000?

! Note: the extra credit is not for you to demonstrate how fast
! your language is compared to others; you need a proper algorithm
! to solve them in a timely manner.

CONSTANT: T1 {
  {  1  2  2 }
  { -2 -1 -2 }
  {  2  2  3 }
}
CONSTANT: T2 {
  {  1  2  2 }
  {  2  1  2 }
  {  2  2  3 }
}
CONSTANT: T3 {
  { -1 -2 -2 }
  {  2  1  2 }
  {  2  2  3 }
}

CONSTANT: base { 3 4 5 }

TUPLE: triplets-count primitives total ;

: <0-triplets-count> ( -- a ) 0 0 \ triplets-count boa ;

: next-triplet ( triplet T -- triplet' )
    [ 1array ] [ mdot ] bi* first ;

: candidates-triplets ( seed -- candidates )
    ${ T1 T2 T3 } [ next-triplet ] with map ;

: add-triplets ( current-triples limit triplet -- stop )
    sum 2dup > [
    /i [ + ] curry change-total
    [ 1 + ] change-primitives drop t
    ] [ 3drop f ] if ;

: all-triplets ( current-triples limit seed -- triplets )
    3dup add-triplets [
        candidates-triplets [ all-triplets ] with swapd reduce
    ] [ 2drop ] if ;

: count-triplets ( limit -- count )
    <0-triplets-count> swap base all-triplets ;

: pprint-triplet-count ( limit count -- )
    [ total>> ] [ primitives>> ] bi
    "Up to %d: %d triples, %d primitives.\n" printf ;

: pyth ( -- )
    8 [1..b] [ 10^ dup count-triplets pprint-triplet-count ] each ;
