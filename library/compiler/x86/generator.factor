! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: compiler-backend
USING: alien arrays assembler compiler inference kernel
kernel-internals lists math memory namespaces sequences words ;

! Not used on x86
M: %prologue generate-node ( vop -- ) 
    drop compile-prologue ;

: (%call)
    label dup postpone-word
    dup primitive? [ address-operand ] when ;

M: %call generate-node ( vop -- )
    drop (%call) CALL ;

M: %jump generate-node ( vop -- )
    drop compile-epilogue (%call) JMP ;

M: %jump-t generate-node ( vop -- )
    drop
    ! Compare input with f
    0 input-operand f address CMP
    ! If not equal, jump
    label JNE ;

M: %return generate-node ( vop -- )
    drop compile-epilogue RET ;

M: %dispatch generate-node ( vop -- )
    #! Compile a piece of code that jumps to an offset in a
    #! jump table indexed by the fixnum at the top of the stack.
    #! The jump table must immediately follow this macro.
    drop
    <label> "end" set
    ! Untag and multiply to get a jump table offset
    0 input-operand fixnum>slot@
    ! Add to jump table base. We use a temporary register since
    ! on AMD4 we have to load a 64-bit immediate. On x86, this
    ! is redundant.
    0 scratch HEX: ffffffff MOV "end" get absolute-cell
    0 input-operand 0 scratch ADD
    ! Jump to jump table entry
    0 input-operand 1array JMP
    ! Align for better performance
    compile-aligned
    ! Fix up jump table pointer
    "end" get save-xt ;

M: %type generate-node ( vop -- )
    #! Intrinstic version of type primitive.
    drop
    <label> "header" set
    <label> "f" set
    <label> "end" set
    ! Make a copy
    0 scratch 0 output-operand MOV
    ! Get the tag
    0 output-operand tag-mask AND
    ! Compare with object tag number (3).
    0 output-operand object-tag CMP
    ! Jump if the object doesn't store type info in its header
    "header" get JE
    ! It doesn't store type info in its header
    0 output-operand tag-bits SHL
    "end" get JMP
    "header" get save-xt
    ! It does store type info in its header
    ! Is the pointer itself equal to 3? Then its F_TYPE (9).
    0 scratch object-tag CMP
    "f" get JE
    ! The pointer is not equal to 3. Load the object header.
    0 output-operand ECX object-tag neg 2array MOV
    ! Mask off header tag, making a fixnum.
    0 output-operand object-tag XOR
    "end" get JMP
    "f" get save-xt
    ! The pointer is equal to 3. Load F_TYPE (9).
    0 output-operand f type tag-bits shift MOV
    "end" get save-xt ;

M: %tag generate-node ( vop -- )
    drop
    0 input-operand tag-mask AND
    0 input-operand tag-bits SHL ;

M: %untag generate-node ( vop -- )
    drop
    0 output-operand tag-mask bitnot AND ;
