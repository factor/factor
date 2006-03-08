! Copyright (C) 2005, 200 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: compiler-backend
USING: alien assembler compiler compiler-frontend inference
kernel kernel-internals lists math memory namespaces words ;

: compile-dlsym ( symbol dll register -- )
    >r 2dup dlsym  r> LOAD32 rel-2/2 rel-dlsym ;

: compile-c-call ( symbol dll -- )
    11 [ compile-dlsym ] keep MTLR  BLRL ;

: stack-increment \ stack-reserve get 32 max stack@ 16 align ;

M: %prologue generate-node ( vop -- )
    drop
    0 input \ stack-reserve set
    1 1 stack-increment neg STWU
    0 MFLR
    0 1 stack-increment lr@ STW ;

: compile-epilogue
    #! At the end of each word that calls a subroutine, we store
    #! the previous link register value in r0 by popping it off
    #! the stack, set the link register to the contents of r0,
    #! and jump to the link register.
    0 1 stack-increment lr@ LWZ
    1 1 stack-increment ADDI
    0 MTLR ;

: word-addr ( word -- )
    #! Load a word address into r3.
    dup word-xt 3 LOAD32  rel-2/2 rel-word ;

: compile-call ( label -- )
    #! Far C call for primitives, near C call for compiled defs.
    dup postpone-word
    dup primitive? [ word-addr  3 MTLR  BLRL ] [ BL ] if ;

M: %call generate-node ( vop -- )
    vop-label compile-call ;

: compile-jump ( label -- )
    #! For tail calls. IP not saved on C stack.
    dup postpone-word
    dup primitive? [ word-addr  3 MTCTR  BCTR ] [ B ] if ;

M: %jump generate-node ( vop -- )
    drop compile-epilogue label compile-jump ;

M: %jump-label generate-node ( vop -- )
    drop label compile-jump ;

M: %jump-t generate-node ( vop -- )
    drop 0 input-operand 0 swap f address CMPI label BNE ;

M: %return generate-node ( vop -- )
    drop compile-epilogue BLR ;

: untag ( dest src -- ) 0 0 31 tag-bits - RLWINM ;

M: %untag generate-node ( vop -- )
    drop dest/src untag ;

: tag-fixnum ( src dest -- ) tag-bits SLWI ;

: untag-fixnum ( src dest -- ) tag-bits SRAWI ;

M: %dispatch generate-node ( vop -- )
    drop
    0 input-operand dup 1 SRAWI
    ! The value 24 is a magic number. It is the length of the
    ! instruction sequence that follows to be generated.
    compiled-offset 24 + 0 scratch LOAD32  rel-2/2 rel-address
    0 input-operand dup 0 scratch ADD
    0 input-operand dup 0 LWZ
    0 input-operand MTLR
    BLR ;

M: %type generate-node ( vop -- )
    drop
    <label> "f" set
    <label> "end" set
    ! Get the tag
    0 input-operand 1 scratch tag-mask ANDI
    ! Tag the tag
    1 scratch 0 scratch tag-fixnum
    ! Compare with object tag number (3).
    0 1 scratch object-tag CMPI
    ! Jump if the object doesn't store type info in its header
    "end" get BNE
    ! It does store type info in its header
    ! Is the pointer itself equal to 3? Then its F_TYPE (9).
    0 0 input-operand object-tag CMPI
    "f" get BEQ
    ! The pointer is not equal to 3. Load the object header.
    0 scratch 0 input-operand object-tag neg LWZ
    0 scratch dup untag
    "end" get B
    "f" get save-xt
    ! The pointer is equal to 3. Load F_TYPE (9).
    f type tag-bits shift 0 scratch LI
    "end" get save-xt
    0 output-operand 0 scratch MR ;

M: %tag generate-node ( vop -- )
    drop dest/src swap tag-mask ANDI
    0 output-operand dup tag-fixnum ;
