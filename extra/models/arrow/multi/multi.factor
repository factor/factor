! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: macros models.arrow models.product fry
generalizations kernel sequences ;
IN: models.arrow.multi

MACRO: <n-arrow> ( int -- quot ) dup
   '[ [ _ narray <product> ] dip [ _ firstn ] prepend <arrow> ] ;

: <2arrow> ( a b quot -- arrow ) 2 <n-arrow> ; inline
: <3arrow> ( a b c quot -- arrow ) 3 <n-arrow> ; inline