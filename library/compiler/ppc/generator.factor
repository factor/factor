! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: compiler
USING: assembler inference kernel kernel-internals lists math
words ;

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

\ slot [
    PEEK-DS
    2unlist type-tag >r cell * r> - >r 18 18 r> LWZ
    REPL-DS
] "generator" set-word-prop

#return-to [
    0 18 LOAD32  absolute-16/16
    1 1 -16 STWU
    18 1 20 STW
] "generator" set-word-prop

#return [ drop compile-epilogue BLR ] "generator" set-word-prop

! Far calls are made to addresses already known when the
! IR node is being generated. No forward reference far
! calls are possible.
: compile-call-far ( word -- )
    19 LOAD32
    19 MTLR
    BLRL ;

: compile-call-label ( label -- )
    dup primitive? [
        dup rel-primitive-16/16 word-xt compile-call-far
    ] [
        0 BL relative-24
    ] ifte ;

#call-label [
    ! Hack: length of instruction sequence that follows
    compiled-offset 20 + 18 LOAD32 rel-address-16/16
    1 1 -16 STWU
    18 1 20 STW
    0 B relative-24
] "generator" set-word-prop

: compile-jump-far ( word -- )
    19 LOAD32
    19 MTCTR
    BCTR ;

: compile-jump-label ( label -- )
    dup primitive? [
        dup rel-primitive-16/16 word-xt compile-jump-far
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

\ dispatch [
    ! Compile a piece of code that jumps to an offset in a
    ! jump table indexed by the fixnum at the top of the stack.
    ! The jump table must immediately follow this macro.
    drop
    POP-DS
    18 18 1 SRAWI
    ! The value 24 is a magic number. It is the length of the
    ! instruction sequence that follows to be generated.
    compiled-offset 24 + 19 LOAD32 rel-address-16/16
    18 18 19 ADD
    18 18 0 LWZ
    18 MTLR
    BLR
] "generator" set-word-prop
