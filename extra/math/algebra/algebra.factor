! Copyright (c) 2007 Samuel Tardieu.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel math sequences ;
IN: math.algebra

: chinese-remainder ( aseq nseq -- x )
    dup product [
        '[ _ over / [ swap gcd drop ] keep * * ] 2map sum
    ] keep rem ; foldable
