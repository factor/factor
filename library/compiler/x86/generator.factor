! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: assembler
USING: alien compiler inference kernel kernel-internals lists
math memory namespaces words ;

! Not used on x86
#prologue [ drop ] "generator" set-word-prop

\ slot [
    PEEK-DS
    2unlist type-tag >r cell * r> - EAX swap 2list EAX swap MOV
    [ ESI ] EAX MOV
] "generator" set-word-prop

: compile-call-label ( label -- ) 0 CALL relative ;
: compile-jump-label ( label -- ) 0 JMP relative ;

#call-label [
    compile-call-label
] "generator" set-word-prop

#jump [
    dup postpone-word  compile-jump-label
] "generator" set-word-prop

: compile-jump-t ( word -- )
    POP-DS
    ! condition is now in EAX
    EAX f address CMP
    ! jump w/ address added later
    0 JNE relative ;

: compile-jump-f ( word -- )
    POP-DS
    ! condition is now in EAX
    EAX f address CMP
    ! jump w/ address added later
    0 JE relative ;

#return-to [ 0 PUSH absolute ] "generator" set-word-prop

#return [ drop RET ] "generator" set-word-prop

\ dispatch [
    #! Compile a piece of code that jumps to an offset in a
    #! jump table indexed by the fixnum at the top of the stack.
    #! The jump table must immediately follow this macro.
    drop
    POP-DS
    EAX 1 SHR
    EAX HEX: ffff ADD  just-compiled f rel-address
    [ EAX ] JMP
    compile-aligned
    compiled-offset swap set-compiled-cell ( fixup -- )
] "generator" set-word-prop
