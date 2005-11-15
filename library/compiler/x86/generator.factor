! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: compiler-backend
USING: alien assembler compiler inference kernel
kernel-internals lists math memory namespaces sequences words ;

! Not used on x86
M: %prologue generate-node drop ;

: compile-dlsym ( symbol dll quot -- )
    >r 2dup dlsym r> call 1 0 rel-dlsym ; inline

: compile-c-call ( symbol dll -- ) [ CALL ] compile-dlsym ;

M: %call generate-node ( vop -- )
    vop-label dup postpone-word CALL ;

M: %call-label generate-node ( vop -- )
    vop-label CALL ;

M: %jump generate-node ( vop -- )
    vop-label dup postpone-word JMP ;

M: %jump-label generate-node ( vop -- )
    vop-label JMP ;

M: %jump-t generate-node ( vop -- )
    dup 0 vop-in v>operand f address CMP vop-label JNE ;

M: %return-to generate-node ( vop -- )
    0 PUSH vop-label absolute ;

M: %return generate-node ( vop -- )
    drop RET ;

M: %dispatch generate-node ( vop -- )
    #! Compile a piece of code that jumps to an offset in a
    #! jump table indexed by the fixnum at the top of the stack.
    #! The jump table must immediately follow this macro.
    0 vop-in v>operand
    ! Untag and multiply by 4 to get a jump table offset
    dup tag-bits 2 - SHR
    ! Add to jump table base
    dup HEX: ffff ADD  just-compiled >r 0 0 rel-address
    ! Jump to jump table entry
    unit JMP
    ! Align for better performance
    compile-aligned
    ! Fix up jump table pointer
    compiled-offset r> set-compiled-cell ( fixup -- ) ;

M: %type generate-node ( vop -- )
    #! Intrinstic version of type primitive.
    <label> "header" set
    <label> "f" set
    <label> "end" set
    0 vop-out v>operand
    ! Make a copy
    ECX over MOV
    ! Get the tag
    dup tag-mask AND
    ! Compare with object tag number (3).
    dup object-tag CMP
    ! Jump if the object doesn't store type info in its header
    "header" get JE
    ! It doesn't store type info in its header
    dup tag-bits SHL
    "end" get JMP
    "header" get save-xt
    ! It does store type info in its header
    ! Is the pointer itself equal to 3? Then its F_TYPE (9).
    ECX object-tag CMP
    "f" get JE
    ! The pointer is not equal to 3. Load the object header.
    dup ECX object-tag neg 2list MOV
    ! Mask off header tag, making a fixnum.
    dup object-tag XOR
    "end" get JMP
    "f" get save-xt
    ! The pointer is equal to 3. Load F_TYPE (9).
    f type tag-bits shift MOV
    "end" get save-xt ;

M: %tag generate-node ( vop -- )
    dup dup 0 vop-in check-dest
    0 vop-in v>operand dup tag-mask AND
    tag-bits SHL ;

M: %untag generate-node ( vop -- )
    0 vop-out v>operand tag-mask bitnot AND ;
