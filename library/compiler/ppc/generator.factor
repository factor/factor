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
    2dup 1 1 rel-dlsym dlsym  19 LOAD32  19 MTLR  BLRL ;

M: integer v>operand tag-bits shift ;
M: vreg v>operand vreg-n 17 + ;

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
    dup 0 1 rel-primitive word-xt 19 LOAD32 ;

: compile-call ( label -- )
    #! Far C call for primitives, near C call for compiled defs.
    dup primitive? [ word-addr  19 MTLR  BLRL ] [ BL ] ifte ;

M: %call generate-node ( vop -- )
    vop-label dup postpone-word compile-call ;

: compile-jump ( label -- )
    #! For tail calls. IP not saved on C stack.
    dup primitive? [ word-addr  19 MTCTR  BCTR ] [ B ] ifte ;

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
    vop-label 0 18 LOAD32  absolute-16/16
    1 1 -16 STWU
    18 1 20 STW ;

M: %return generate-node ( vop -- )
    drop compile-epilogue BLR ;

M: %untag generate-node ( vop -- )
    dest/src 0 0 28 RLWINM ;

M: %untag-fixnum generate-node ( vop -- )
    dest/src tag-bits SRAWI ;

M: %tag-fixnum generate-node ( vop -- )
    ! todo: formalize scratch register usage
    3 19 LI
    dest/src 19 SLW ;

M: %dispatch generate-node ( vop -- )
    0 <vreg> check-src
    2 18 LI
    17 17 18 SLW
    ! The value 24 is a magic number. It is the length of the
    ! instruction sequence that follows to be generated.
    0 1 rel-address  compiled-offset 24 + 18 LOAD32
    17 17 18 ADD
    17 17 0 LWZ
    17 MTLR
    BLR ;

M: %type generate-node ( vop -- )
    0 <vreg> check-src
    <label> "f" set
    <label> "end" set
    ! Get the tag
    17 18 tag-mask ANDI
    ! Compare with object tag number (3).
    0 18 object-tag CMPI
    ! Jump if the object doesn't store type info in its header
    "end" get BNE
    ! It does store type info in its header
    ! Is the pointer itself equal to 3? Then its F_TYPE (9).
    0 17 object-tag CMPI
    "f" get BEQ
    ! The pointer is not equal to 3. Load the object header.
    18 17 object-tag neg LWZ
    18 18 3 SRAWI
    "end" get B
    "f" get save-xt
    ! The pointer is equal to 3. Load F_TYPE (9).
    f type 18 LI
    "end" get save-xt
    18 17 MR ;

M: %arithmetic-type generate-node ( vop -- )
    0 <vreg> check-dest
    <label> "end" set
    ! Load top two stack values
    17 14 -4 LWZ
    18 14 0 LWZ
    ! Compute their tags
    17 17 tag-mask ANDI
    18 18 tag-mask ANDI
    ! Are the tags equal?
    0 17 18 CMPL
    "end" get BEQ
    ! No, they are not equal. Call a runtime function to
    ! coerce the integers to a higher type.
    "arithmetic_type" f compile-c-call
    "end" get save-xt ;
