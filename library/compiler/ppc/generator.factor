! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: compiler
USING: assembler inference kernel words ;

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
#epilogue [
    drop
    0 1 0 LWZ
    1 1 4 ADDI
    0 MTLR
] "generator" set-word-prop

#return [ drop BLR ] "generator" set-word-prop
