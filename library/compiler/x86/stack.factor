! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: compiler
USING: inference kernel assembler words lists alien memory ;

: rel-ds ( -- )
    #! Add an entry to the relocation table for the 32-bit
    #! immediate just compiled.
    "ds" f f rel-dlsym ;

: DS ( -- [ address ] ) "ds" f dlsym unit ;
: DS> ( register -- ) DS MOV rel-ds ;
: >DS ( register -- ) DS swap MOV rel-ds ;

: rel-cs ( -- )
    #! Add an entry to the relocation table for the 32-bit
    #! immediate just compiled.
    "cs" f f rel-dlsym ;

: CS ( -- [ address ] ) "cs" f dlsym unit ;
: CS> ( register -- ) CS MOV rel-cs ;
: >CS ( register -- ) CS swap MOV rel-cs ;

: PEEK-DS ( -- )
    #! Peek datastack to EAX.
    ECX DS>
    EAX [ ECX ] MOV ;

: POP-DS ( -- )
    #! Pop datastack to EAX.
    PEEK-DS
    ECX 4 SUB
    ECX >DS ;

: PUSH-DS ( -- )
    #! Push EAX to datastack.
    ECX 4 ADD
    [ ECX ] EAX MOV
    ECX >DS ;

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
    [ ECX ] swap address MOV ;

: indirect-literal ( obj -- )
    ( EAX [ obj ] MOV )
    EAX swap intern-literal unit MOV  rel-address ;

#push-immediate [
    ECX DS>
    ECX 4 ADD
    immediate-literal
    ECX >DS
] "generator" set-word-property

#push-indirect [
    ECX DS>
    indirect-literal
    PUSH-DS
] "generator" set-word-property

#replace-immediate [
    ECX DS>
    immediate-literal
] "generator" set-word-property

#replace-indirect [
    ECX DS>
    indirect-literal
    [ ECX ] EAX MOV
] "generator" set-word-property

\ drop [
    drop
    ECX DS>
    ECX 4 SUB
    ECX >DS
] "generator" set-word-property

\ dup [
    drop
    PEEK-DS
    PUSH-DS
] "generator" set-word-property

\ swap [
    drop
    ECX DS>
    EAX [ ECX ] MOV
    EDX [ ECX -4 ] MOV
    [ ECX ] EDX MOV
    [ ECX -4 ] EAX MOV
] "generator" set-word-property

\ over [
    drop
    ECX DS>
    EAX [ ECX -4 ] MOV
    PUSH-DS
] "generator" set-word-property

\ pick [
    drop
    ECX DS>
    EAX [ ECX -8 ] MOV
    PUSH-DS
] "generator" set-word-property

\ >r [
    drop
    POP-DS
    ECX CS>
    PUSH-CS
] "generator" set-word-property

\ r> [
    drop
    POP-CS
    ECX DS>
    PUSH-DS
] "generator" set-word-property
