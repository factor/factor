! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: assembler
USING: errors kernel math memory words ;

: PUSH-DS
    #! Push r18 on the data stack.
    18 14 4 STWU ;

: w>h/h dup -16 shift HEX: ffff bitand >r HEX: ffff bitand r> ;

: immediate-literal ( obj -- )
    #! PowerPC cannot load a 32 bit literal in one instruction.
    address dup HEX: ffff <= [
        18 LI
    ] [
        w>h/h 18 LIS  18 18 rot ORI
    ] ifte  PUSH-DS ;

: PUSH-CS
    #! Push r18 on the return stack.
    18 15 4 STWU ;
