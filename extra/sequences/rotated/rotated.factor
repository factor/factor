! Copyright (C) 2012 John Benediktsson
! See http://factorcode.org/license.txt for BSD license
USING: accessors circular kernel math sequences ;
IN: sequences.rotated

TUPLE: rotated
{ circular circular read-only }
{ n integer read-only } ;

: <rotated> ( seq n -- rotated )
    [ <circular> ] dip rotated boa ;

M: rotated length circular>> length ;

M: rotated virtual@ [ n>> + ] [ circular>> ] bi ;

M: rotated virtual-exemplar circular>> ;

INSTANCE: rotated virtual-sequence
