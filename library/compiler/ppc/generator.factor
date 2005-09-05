! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: compiler-backend
USING: alien assembler compiler inference kernel
kernel-internals lists math memory namespaces words ;

! PowerPC register assignments
! r14 data stack
! r15 call stack
! r16-r30 vregs

: compile-c-call ( symbol dll -- )
    2dup dlsym  19 LOAD32  0 1 rel-dlsym  19 MTLR  BLRL ;

M: %prologue generate-node ( vop -- )
    drop
    1 1 -16 STWU
    0 MFLR
    0 1 20 STW ;

: compile-epilogue
    #! At the end of each word that calls a subroutine, we store
    #! the previous link register value in r0 by popping it off
    #! the stack, set the link register to the contents of r0,
    #! and jump to the link register.
    0 1 20 LWZ
    1 1 16 ADDI
    0 MTLR ;

M: %call-label generate-node ( vop -- )
    #! Near calling convention for inlined recursive combinators
    #! Note: length of instruction sequence is hard-coded.
    vop-label
    0 1 rel-address  compiled-offset 20 + 18 LOAD32
    1 1 -16 STWU
    18 1 20 STW
    B ;

: word-addr ( word -- )
    #! Load a word address into r3.
    dup word-xt 3 LOAD32  0 1 rel-word ;

: compile-call ( label -- )
    #! Far C call for primitives, near C call for compiled defs.
    dup primitive? [ word-addr  3 MTLR  BLRL ] [ BL ] ifte ;

M: %call generate-node ( vop -- )
    vop-label dup postpone-word compile-call ;

: compile-jump ( label -- )
    #! For tail calls. IP not saved on C stack.
    dup primitive? [ word-addr  3 MTCTR  BCTR ] [ B ] ifte ;

M: %jump generate-node ( vop -- )
    vop-label dup postpone-word  compile-epilogue compile-jump ;

M: %jump-label generate-node ( vop -- )
    vop-label B ;

: conditional ( vop -- label )
    dup vop-in-1 v>operand 0 swap f address CMPI vop-label ;

M: %jump-f generate-node ( vop -- )
    conditional BEQ ;

M: %jump-t generate-node ( vop -- )
    conditional BNE ;

M: %return-to generate-node ( vop -- )
    vop-label 0 3 LOAD32  absolute-16/16
    1 1 -16 STWU
    3 1 20 STW ;

M: %return generate-node ( vop -- )
    drop compile-epilogue BLR ;

: untag ( dest src -- ) 0 0 31 tag-bits - RLWINM ;

M: %untag generate-node ( vop -- )
    dest/src untag ;

M: %untag-fixnum generate-node ( vop -- )
    dest/src tag-bits SRAWI ;

: tag-fixnum ( dest src -- ) tag-bits SLWI ;

M: %retag-fixnum generate-node ( vop -- )
    ! todo: formalize scratch register usage
    dest/src tag-fixnum ;

M: %dispatch generate-node ( vop -- )
    0 <vreg> check-src
    3 3 2 SLWI
    ! The value 24 is a magic number. It is the length of the
    ! instruction sequence that follows to be generated.
    0 1 rel-address  compiled-offset 24 + 4 LOAD32
    3 3 4 ADD
    3 3 0 LWZ
    3 MTLR
    BLR ;

M: %type generate-node ( vop -- )
    0 <vreg> check-src
    <label> "f" set
    <label> "end" set
    ! Get the tag
    3 4 tag-mask ANDI
    ! Compare with object tag number (3).
    0 4 object-tag CMPI
    ! Jump if the object doesn't store type info in its header
    "end" get BNE
    ! It does store type info in its header
    ! Is the pointer itself equal to 3? Then its F_TYPE (9).
    0 3 object-tag CMPI
    "f" get BEQ
    ! The pointer is not equal to 3. Load the object header.
    4 3 object-tag neg LWZ
    4 4 3 SRAWI
    "end" get B
    "f" get save-xt
    ! The pointer is equal to 3. Load F_TYPE (9).
    f type 4 LI
    "end" get save-xt
    3 4 MR ;

M: %tag generate-node ( vop -- )
    dup vop-in-1 v>operand swap vop-out-1 v>operand tag-mask ANDI ;
