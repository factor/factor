! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: compiler
USING: alien assembler inference kernel kernel-internals lists
math memory namespaces words ;

\ slot [
    PEEK-DS
    ( EAX [ EAX 3 ] MOV )
    2unlist type-tag >r cell * r> - EAX swap 2list EAX swap MOV
    [ ECX ] EAX MOV
] "generator" set-word-property

: compile-call-label ( label -- )
    0 CALL fixup compiled-offset defer-xt ;

: compile-jump-label ( label -- )
    0 JMP fixup compiled-offset defer-xt ;

: compile-call ( word -- )
    dup dup postpone-word  compile-call-label  t rel-word ;

: compile-target ( word -- )
    compiled-offset 0 compile-cell 0 defer-xt ;

#call [
    compile-call
] "generator" set-word-property

#jump [
    dup dup postpone-word
    compile-jump-label
    t rel-word
] "generator" set-word-property

#call-label [
    compile-call-label
] "generator" set-word-property

#jump-label [
    compile-jump-label
] "generator" set-word-property

#jump-t [
    POP-DS
    ! condition is now in EAX
    EAX f address CMP
    ! jump w/ address added later
    0 JNE fixup compiled-offset defer-xt
] "generator" set-word-property

#return-to [
    0 PUSH fixup 0 defer-xt rel-address
] "generator" set-word-property

#return [ drop RET ] "generator" set-word-property

\ dispatch [
    #! Compile a piece of code that jumps to an offset in a
    #! jump table indexed by the fixnum at the top of the stack.
    #! The jump table must immediately follow this macro.
    drop
    POP-DS
    EAX 1 SHR
    EAX HEX: ffff ADD fixup rel-address
    [ EAX ] JMP
    compile-aligned
    compiled-offset swap set-compiled-cell ( fixup -- )
] "generator" set-word-property

#target-label [
    #! Jump table entries are absolute addresses.
    compile-target rel-address
] "generator" set-word-property

#target [
    #! Jump table entries are absolute addresses.
    dup dup postpone-word compile-target f rel-word
] "generator" set-word-property

#c-call [
    uncons load-dll 2dup dlsym CALL t rel-dlsym
] "generator" set-word-property

#unbox [
    dup f dlsym CALL f t rel-dlsym
    EAX PUSH
] "generator" set-word-property

#box [
    EAX PUSH
    dup f dlsym CALL f t rel-dlsym
    ESP 4 ADD
] "generator" set-word-property

#cleanup [
    dup 0 = [ drop ] [ ESP swap ADD ] ifte
] "generator" set-word-property
