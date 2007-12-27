! Copyright (c) 2007 Samuel Tardieu
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math math.ranges namespaces sequences vars ;
IN: math.algebra

<PRIVATE

! The traditional name for the first variable is "r", but we want to avoid
! a redefinition of "r>" and ">r", so we chose to use "s" instead.

VARS: s-1 u-1 v-1 s u v ;

: init ( a b -- )
  >s >s-1 0 >u 1 >u-1 1 >v 0 >v-1 ;

: advance ( r u v -- )
  v> >v-1 >v u> >u-1 >u s> >s-1 >s ; inline

: step ( -- )
  s-1> s> 2dup /mod drop [ * - ] keep u-1> over u> * - v-1> rot v> * -
  advance ;

PRIVATE>

! Extended Euclidian: http://en.wikipedia.org/wiki/Extended_Euclidean_algorithm
: ext-euclidian ( a b -- gcd u v )
  [ init [ s> 0 > ] [ step ] [ ] while s-1> u-1> v-1> ] with-scope ; foldable

! Inverse a in ring Z/bZ
: ring-inverse ( a b -- i )
  [ ext-euclidian drop nip ] keep rem ; foldable

! Chinese remainder: http://en.wikipedia.org/wiki/Chinese_remainder_theorem
: chinese-remainder ( aseq nseq -- x )
  dup product
  [ [ over / [ ext-euclidian ] keep * 2nip * ] curry 2map sum ] keep rem ;
  foldable
