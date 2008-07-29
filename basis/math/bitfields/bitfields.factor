! Copyright (C) 2007, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays kernel math sequences words
namespaces inference.transforms ;
IN: math.bitfields

GENERIC: (bitfield) ( value accum shift -- newaccum )

M: integer (bitfield) ( value accum shift -- newaccum )
    swapd shift bitor ;

M: pair (bitfield) ( value accum pair -- newaccum )
    first2 >r dup word? [ swapd execute ] when r> shift bitor ;

: bitfield ( values... bitspec -- n )
    0 [ (bitfield) ] reduce ;

: flags ( values -- n )
    0 [ dup word? [ execute ] when bitor ] reduce ;

GENERIC: (bitfield-quot) ( spec -- quot )

M: integer (bitfield-quot) ( spec -- quot )
    [ swapd shift bitor ] curry ;

M: pair (bitfield-quot) ( spec -- quot )
    first2 over word? [ >r swapd execute r> ] [ ] ?
    [ shift bitor ] append 2curry ;

: bitfield-quot ( spec -- quot )
    [ (bitfield-quot) ] map [ 0 ] prefix concat ;

\ bitfield [ bitfield-quot ] 1 define-transform

\ flags [
    [ 0 , [ , \ bitor , ] each ] [ ] make
] 1 define-transform
