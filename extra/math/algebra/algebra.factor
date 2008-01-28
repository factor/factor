! Copyright (c) 2007 Samuel Tardieu
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math math.functions sequences ;
IN: math.algebra

: chinese-remainder ( aseq nseq -- x )
  dup product
  [ [ over / [ swap gcd drop ] keep * * ] curry 2map sum ] keep rem ; foldable
