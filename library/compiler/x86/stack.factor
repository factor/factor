! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: compiler
USING: inference kernel assembler words lists alien memory ;

: rel-cs ( -- )
    #! Add an entry to the relocation table for the 32-bit
    #! immediate just compiled.
    "cs" f f rel-dlsym ;

: CS ( -- [ address ] ) "cs" f dlsym unit ;
: CS> ( register -- ) CS MOV rel-cs ;
: >CS ( register -- ) CS swap MOV rel-cs ;

: PEEK-DS ( -- )
    #! Peek datastack to EAX.
    EAX [ ESI ] MOV ;

: POP-DS ( -- )
    #! Pop datastack to EAX.
    PEEK-DS
    ESI 4 SUB ;

: PUSH-DS ( -- )
    #! Push EAX to datastack.
    ESI 4 ADD
    [ ESI ] EAX MOV ;

: PEEK-CS ( -- )
    #! Peek return stack to EAX.
    ECX CS>
    EAX [ ECX ] MOV ;

: POP-CS ( -- )
    #! Pop return stack to EAX.
    PEEK-CS
    ECX 4 SUB
    ECX >CS ;

: PUSH-CS ( -- )
    #! Push EAX to return stack.
    ECX 4 ADD
    [ ECX ] EAX MOV
    ECX >CS ;

: immediate-literal ( obj -- )
    [ ESI ] swap address MOV ;

: indirect-literal ( obj -- )
    EAX swap intern-literal unit MOV  f rel-address ;

#push-immediate [
    ESI 4 ADD
    immediate-literal
] "generator" set-word-prop

#push-indirect [
    indirect-literal
    PUSH-DS
] "generator" set-word-prop

#replace-immediate [
    immediate-literal
] "generator" set-word-prop

#replace-indirect [
    indirect-literal
    [ ESI ] EAX MOV
] "generator" set-word-prop

\ drop [
    drop
    ESI 4 SUB
] "generator" set-word-prop

\ dup [
    drop
    PEEK-DS
    PUSH-DS
] "generator" set-word-prop

\ swap [
    drop
    EAX [ ESI ] MOV
    EDX [ ESI -4 ] MOV
    [ ESI ] EDX MOV
    [ ESI -4 ] EAX MOV
] "generator" set-word-prop

\ over [
    drop
    EAX [ ESI -4 ] MOV
    PUSH-DS
] "generator" set-word-prop

\ pick [
    drop
    EAX [ ESI -8 ] MOV
    PUSH-DS
] "generator" set-word-prop

\ >r [
    drop
    POP-DS
    ECX CS>
    PUSH-CS
] "generator" set-word-prop

\ r> [
    drop
    POP-CS
    PUSH-DS
] "generator" set-word-prop
