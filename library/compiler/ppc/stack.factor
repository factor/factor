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

: indirect-literal ( obj -- )
    intern-literal 19 LOAD
    18 19 0 LWZ ;

#push-immediate [
     address 18 LOAD PUSH-DS
] "generator" set-word-prop

#push-indirect [
    indirect-literal  PUSH-DS
] "generator" set-word-prop

#replace-immediate [
     address 18 LOAD REPL-DS
] "generator" set-word-prop

#replace-indirect [
    indirect-literal  REPL-DS
] "generator" set-word-prop

\ drop [ drop  14 14 4 SUBI ] "generator" set-word-prop
\ dup [ drop  PEEK-DS PUSH-DS ] "generator" set-word-prop
\ over [ drop  18 14 -4 LWZ  PUSH-DS ] "generator" set-word-prop
\ pick [ drop  18 14 -8 LWZ  PUSH-DS ] "generator" set-word-prop

\ swap [
    drop
    18 14 -4 LWZ
    19 14 0 LWZ
    19 14 -4 STW
    18 14 0 STW
] "generator" set-word-prop

\ >r [ drop  POP-DS PUSH-CS ] "generator" set-word-prop
\ r> [ drop  POP-CS PUSH-DS ] "generator" set-word-prop
