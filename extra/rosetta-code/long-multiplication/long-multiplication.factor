! Copyright (c) 2012 Anonymous
! See https://factorcode.org/license.txt for BSD license.
USING: kernel math math.vectors sequences ;
IN: rosetta-code.long-multiplication

! https://rosettacode.org/wiki/Long_multiplication

! In this task, explicitly implement long multiplication. This
! is one possible approach to arbitrary-precision integer algebra.

! For output, display the result of 2^64 * 2^64. The decimal
! representation of 2^64 is:

! 18446744073709551616

! The output of 2^64 * 2^64 is 2^128, and that is:

! 340282366920938463463374607431768211456

: longmult-seq ( xs ys -- zs )
    [ * ] cartesian-map
    dup length <iota> [ 0 <repetition> ] map
    [ prepend ] 2map
    [ ] [ [ 0 suffix ] dip v+ ] map-reduce ;

: integer->digits ( x -- xs )
    { } swap  [ dup 0 > ] [ 10 /mod swap [ prefix ] dip ] while  drop ;

: digits->integer ( xs -- x )
    0 [ swap 10 * + ] reduce ;

: longmult ( x y -- z )
    [ integer->digits ] bi@ longmult-seq digits->integer ;
