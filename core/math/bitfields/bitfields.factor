! Copyright (C) 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays kernel math sequences words ;
IN: math.bitfields

GENERIC: (bitfield) inline

M: integer (bitfield) ( value accum shift -- newaccum )
    swapd shift bitor ;

M: pair (bitfield) ( value accum pair -- newaccum )
    first2 >r dup word? [ swapd execute ] when r> shift bitor ;

: bitfield ( values... bitspec -- n )
    0 [ (bitfield) ] reduce ;
