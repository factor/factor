! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: assembler
USING: compiler errors kernel math memory words ;

! Pushing and popping the data stack.
: PEEK-DS 18 14 0 LWZ ;
: POP-DS PEEK-DS 14 14 4 SUBI ;
: PUSH-DS 18 14 4 STWU ;
: REPL-DS 18 14 0 STW ;

! Pushing and popping the return stack.
: PEEK-CS 18 15 0 LWZ ;
: POP-CS PEEK-CS 15 15 4 SUBI ;
: PUSH-CS 18 15 4 STWU ;

: w>h/h dup -16 shift HEX: ffff bitand >r HEX: ffff bitand r> ;

: immediate-literal ( obj -- )
    #! PowerPC cannot load a 32 bit literal in one instruction.
    address dup HEX: ffff <= [
        18 LI
    ] [
        w>h/h 18 LIS  18 18 rot ORI
    ] ifte ;

#push-immediate [
    immediate-literal  PUSH-DS
] "generator" set-word-prop

#replace-immediate [
    immediate-literal  REPL-DS
] "generator" set-word-prop

\ drop [ drop  14 14 4 SUBI ] "generator" set-word-prop
\ dup [ drop  PEEK-DS PUSH-DS ] "generator" set-word-prop
\ over [ drop  18 14 -4 LWZ  PUSH-DS ] "generator" set-word-prop
\ pick [ drop  18 14 -8 LWZ  PUSH-DS ] "generator" set-word-prop
\ >r [ drop  POP-DS PUSH-CS ] "generator" set-word-prop
\ r> [ drop  POP-CS PUSH-DS ] "generator" set-word-prop
