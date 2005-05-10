! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: compiler-backend
USING: alien assembler compiler inference kernel
kernel-internals lists math memory namespaces sequences words ;

GENERIC: v>operand
M: integer v>operand tag-bits shift ;
M: vreg v>operand vreg-n { EAX ECX EDX } nth ;

: dest/src ( vop -- dest src )
    dup vop-dest v>operand swap vop-source v>operand ;

! Not used on x86
M: %prologue generate-node drop ;

: compile-c-call ( symbol dll -- )
    2dup dlsym CALL t rel-dlsym ;

M: %call generate-node ( vop -- )
    vop-label dup postpone-word CALL ;

M: %jump-label generate-node ( vop -- )
    vop-label JMP ;

M: %call-label generate-node ( vop -- )
    vop-label CALL ;

M: %jump generate-node ( vop -- )
    vop-label dup postpone-word JMP ;

M: %jump-f generate-node ( vop -- )
    dup vop-source v>operand f address CMP vop-label JE ;

M: %jump-t generate-node ( vop -- )
    dup vop-source v>operand f address CMP vop-label JNE ;

M: %return-to generate-node ( vop -- )
    0 PUSH vop-label absolute ;

M: %return generate-node ( vop -- )
    drop RET ;

M: %untag generate-node ( vop -- )
    vop-dest v>operand BIN: 111 bitnot AND ;

M: %tag-fixnum generate-node ( vop -- )
    vop-dest v>operand 3 SHL ;

M: %untag-fixnum generate-node ( vop -- )
    vop-dest v>operand 3 SHR ;

M: %slot generate-node ( vop -- )
    #! the untagged object is in vop-dest, the tagged slot
    #! number is in vop-source.
    dest/src
    ! turn tagged fixnum slot # into an offset, multiple of 4
    dup 1 SHR
    ! compute slot address in vop-dest
    dupd ADD
    ! load slot value in vop-dest
    dup unit MOV ;

M: %fast-slot generate-node ( vop -- )
    #! the tagged object is in vop-dest, the pointer offset is
    #! in vop-literal. the offset already takes the type tag
    #! into account, so its just one instruction to load.
    dup vop-literal swap vop-dest v>operand tuck >r 2list r>
    swap MOV ;

M: %set-slot generate-node ( vop -- )
    #! the untagged object is in vop-dest, the new value is in
    #! vop-source, the tagged slot number is in vop-literal.
    dup vop-literal v>operand over vop-dest v>operand
    ! turn tagged fixnum slot # into an offset, multiple of 4
    over 1 SHR
    ! compute slot address in vop-dest
    dupd ADD
    ! store new slot value
    >r vop-source v>operand r> unit swap MOV ;

M: %fast-set-slot generate-node ( vop -- )
    #! the tagged object is in vop-dest, the new value is in
    #! vop-source, the pointer offset is in vop-literal. the
    #! offset already takes the type tag into account, so its
    #! just one instruction to load.
    dup vop-literal over vop-dest v>operand swap 2list
    swap vop-source v>operand MOV ;

M: %dispatch generate-node ( vop -- )
    #! Compile a piece of code that jumps to an offset in a
    #! jump table indexed by the fixnum at the top of the stack.
    #! The jump table must immediately follow this macro.
    vop-source v>operand
    ! Multiply by 4 to get a jump table offset
    dup 2 SHL
    ! Add to jump table base
    dup HEX: ffff ADD  just-compiled >r f rel-address
    ! Jump to jump table entry
    unit JMP
    ! Align for better performance
    compile-aligned
    ! Fix up jump table pointer
    compiled-offset r> set-compiled-cell ( fixup -- ) ;

M: %type generate-node ( vop -- )
    #! Intrinstic version of type primitive. It outputs an
    #! UNBOXED value in vop-dest.
    <label> "f" set
    <label> "end" set
    vop-dest v>operand
    ! Make a copy
    ECX over MOV
    ! Get the tag
    dup tag-mask AND
    ! Compare with object tag number (3).
    dup object-tag CMP
    ! Jump if the object doesn't store type info in its header
    "end" get JNE
    ! It doesn't store type info in its header
    ! It does store type info in its header
    ! Is the pointer itself equal to 3? Then its F_TYPE (9).
    ECX object-tag CMP
    "f" get JE
    ! The pointer is not equal to 3. Load the object header.
    dup ECX object-tag neg 2list MOV
    dup 3 SHR
    "end" get JMP
    "f" get save-xt
    ! The pointer is equal to 3. Load F_TYPE (9).
    f type MOV
    "end" get save-xt ;

M: %arithmetic-type generate-node ( vop -- )
    #! This one works directly with the stack. It outputs an
    #! UNBOXED value in vop-dest.
    0 <vreg> check-dest
    <label> "end" set
    ! Load top two stack values
    EAX [ ESI -4 ] MOV
    ECX [ ESI ] MOV
    ! Compute their tags
    EAX BIN: 111 AND
    ECX BIN: 111 AND
    ! Are the tags equal?
    EAX ECX CMP
    "end" get JE
    ! No, they are not equal. Call a runtime function to
    ! coerce the integers to a higher type.
    "arithmetic_type" f compile-c-call
    "end" get save-xt ;
