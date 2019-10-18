! Copyright (C) 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: math
USING: arrays kernel sequences words ;

GENERIC: (bitfield) inline

M: integer (bitfield) ( value accum shift -- newaccum )
    swapd shift bitor ;

M: pair (bitfield) ( value accum pair -- newaccum )
    first2 >r dup word? [ swapd execute ] when r> shift bitor ;

: bitfield ( ...values... bitspec -- n )
    #! Spec is an array of integers or { constant/word shift }
    #! pairs.
    0 [ (bitfield) ] reduce ;
