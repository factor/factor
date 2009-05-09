! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: macros ui.frp models.product fry
generalizations kernel sequences ;
IN: models.mapped

MACRO: <n-mapped> ( int -- quot ) dup
   '[ [ _ narray <product> ] dip [ _ firstn ] prepend <mapped> ] ;

: <2mapped> ( a b quot -- arrow ) 2 <n-mapped> ; inline
: <3mapped> ( a b c quot -- arrow ) 3 <n-mapped> ; inline