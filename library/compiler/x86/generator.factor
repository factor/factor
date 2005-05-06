! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: assembler
USING: alien compiler inference kernel kernel-internals lists
math memory namespaces sequences words ;

GENERIC: v>operand
M: integer v>operand ;
M: vreg v>operand vreg-n { EAX ECX EDX } nth ;

! Not used on x86
M: %prologue generate-node drop ;

: compile-call-label ( label -- ) 0 CALL relative ;
: compile-jump-label ( label -- ) 0 JMP relative ;

M: %call-label generate-node ( vop -- )
    vop-label compile-call-label ;

M: %jump generate-node ( vop -- )
    vop-label dup postpone-word  compile-jump-label ;

M: %jump-f generate-node ( vop -- )
    dup vop-source v>operand f address CMP 0 JNE
    vop-label relative ;

M: %jump-t generate-node ( vop -- )
    dup vop-source v>operand f address CMP 0 JE
    vop-label relative ;

M: %return-to generate-node ( vop -- )
    0 PUSH vop-label absolute ;

M: %return generate-node ( vop -- )
    drop RET ;

M: %untag generate-node ( vop -- )
    vop-source v>operand BIN: 111 bitnot AND ;

M: %slot generate-node ( vop -- )
    #! the untagged object is in vop-dest, the tagged slot
    #! number is in vop-literal.
    dup vop-literal v>operand swap vop-dest v>operand
    ! turn tagged fixnum slot # into an offset, multiple of 4
    over 1 SHR
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
    vop-source v>operand dup 1 SHR
    dup HEX: ffff ADD  just-compiled >r f rel-address
    unit JMP
    compile-aligned
    compiled-offset r> set-compiled-cell ( fixup -- ) ;

M: %type generate-node ( vop -- )
    #! Intrinstic version of type primitive.
    <label> "object" set
    <label> "f" set
    <label> "end" set
    vop-source v>operand
    ! Make a copy
    ECX over MOV
    ! Get the tag
    dup tag-mask AND
    ! Compare with object tag number (3).
    dup object-tag CMP
    ! Jump if the object stores type info in its header
    "object" get 0 JE relative
    ! It doesn't store type info in its header
    dup tag-bits SHL
    "end" get compile-jump-label
    "object" get save-xt
    ! It does store type info in its header
    ! Is the pointer itself equal to 3? Then its F_TYPE (9).
    ECX object-tag CMP
    "f" get 0 JE relative
    ! The pointer is not equal to 3. Load the object header.
    dup ECX object-tag neg 2list MOV
    ! Headers have tag 3. Clear the tag to turn it into a fixnum.
    dup object-tag XOR
    "end" get compile-jump-label
    "f" get save-xt
    ! The pointer is equal to 3. Load F_TYPE (9).
    f type tag-bits shift MOV
    "end" get save-xt ;
