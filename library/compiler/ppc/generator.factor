! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: compiler
USING: assembler inference kernel math words ;

! At the start of each word that calls a subroutine, we store
! the link register in r0, then push r0 on the C stack.
#prologue [
    drop
    0 MFLR
    0 1 -4 STWU
] "generator" set-word-prop

! At the end of each word that calls a subroutine, we store
! the previous link register value in r0 by popping it off the
! stack, set the link register to the contents of r0, and jump
! to the link register.
: compile-epilogue
    0 1 0 LWZ
    1 1 4 ADDI
    0 MTLR ;

#epilogue [ drop compile-epilogue ] "generator" set-word-prop

#return [ drop BLR ] "generator" set-word-prop

! Far calls are made to addresses already known when the
! IR node is being generated. No forward reference far
! calls are possible.
: compile-call-far ( n -- )
    19 LOAD
    19 MTLR
    BLRL ;

: compile-call-label ( label -- )
    dup primitive? [
        word-xt compile-call-far
    ] [
        0 BL relative-24
    ] ifte ;

: compile-jump-label ( label -- )
    compile-epilogue  0 B relative-24 ;

: compile-jump-t ( label -- )
    POP-DS
    0 18 3 CMPI
    0 BNE  relative-14 ;
