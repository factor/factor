! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: compiler
USING: assembler inference kernel math words ;

! At the start of each word that calls a subroutine, we store
! the link register in r0, then push r0 on the C stack.
#prologue [
    drop
    1 1 -16 STWU
    0 MFLR
    0 1 20 STW
] "generator" set-word-prop

! At the end of each word that calls a subroutine, we store
! the previous link register value in r0 by popping it off the
! stack, set the link register to the contents of r0, and jump
! to the link register.
: compile-epilogue
    0 1 20 LWZ
    1 1 16 ADDI
    0 MTLR ;

! #return-to [
!     
! ] "generator" set-word-prop

#return [ drop compile-epilogue BLR ] "generator" set-word-prop

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

: compile-jump-far ( n -- )
    19 LOAD
    19 MTCTR
    BCTR ;

: compile-jump-label ( label -- )
    dup primitive? [
        word-xt compile-jump-far
    ] [
        0 B relative-24
    ] ifte ;

#jump [
    dup postpone-word  compile-epilogue  compile-jump-label
] "generator" set-word-prop

: compile-jump-t ( label -- )
    POP-DS
    0 18 3 CMPI
    0 BNE  relative-14 ;

: compile-jump-f ( label -- )
    POP-DS
    0 18 3 CMPI
    0 BEQ  relative-14 ;
