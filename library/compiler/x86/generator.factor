! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: compiler
USING: alien assembler inference kernel kernel-internals lists
math memory namespaces words ;

\ slot [
    PEEK-DS
    2unlist type-tag >r cell * r> - EAX swap 2list EAX swap MOV
    [ ESI ] EAX MOV
] "generator" set-word-prop

: compile-call-label ( label -- ) 0 CALL fixup t defer-xt ;
: compile-jump-label ( label -- ) 0 JMP fixup t defer-xt ;

: compile-call ( word -- )
    dup postpone-word  compile-call-label ;

: compile-target ( word -- )
    compiled-offset 0 compile-cell f defer-xt ;

#call [
    compile-call
] "generator" set-word-prop

#jump [
    dup postpone-word  compile-jump-label
] "generator" set-word-prop

#call-label [
    compile-call-label
] "generator" set-word-prop

#jump-label [
    compile-jump-label
] "generator" set-word-prop

: compile-jump-t ( word -- )
    POP-DS
    ! condition is now in EAX
    EAX f address CMP
    ! jump w/ address added later
    0 JNE fixup t defer-xt ;

#jump-t-label [ compile-jump-t ] "generator" set-word-prop

#jump-t [ compile-jump-t ] "generator" set-word-prop

: compile-jump-f ( word -- )
    POP-DS
    ! condition is now in EAX
    EAX f address CMP
    ! jump w/ address added later
    0 JE fixup t defer-xt ;

#jump-f-label [ compile-jump-f ] "generator" set-word-prop

#jump-f [ compile-jump-f ] "generator" set-word-prop

#return-to [ 0 PUSH fixup f defer-xt ] "generator" set-word-prop

#return [ drop RET ] "generator" set-word-prop

\ dispatch [
    #! Compile a piece of code that jumps to an offset in a
    #! jump table indexed by the fixnum at the top of the stack.
    #! The jump table must immediately follow this macro.
    drop
    POP-DS
    EAX 1 SHR
    EAX HEX: ffff ADD fixup f rel-address
    [ EAX ] JMP
    compile-aligned
    compiled-offset swap set-compiled-cell ( fixup -- )
] "generator" set-word-prop

#target-label [
    #! Jump table entries are absolute addresses.
    compile-target
] "generator" set-word-prop

#target [
    #! Jump table entries are absolute addresses.
    dup postpone-word compile-target
] "generator" set-word-prop

#c-call [
    uncons load-dll 2dup dlsym CALL t rel-dlsym
] "generator" set-word-prop

#unbox [
    dup f dlsym CALL f t rel-dlsym
    EAX PUSH
] "generator" set-word-prop

#box [
    EAX PUSH
    dup f dlsym CALL f t rel-dlsym
    ESP 4 ADD
] "generator" set-word-prop

#cleanup [
    dup 0 = [ drop ] [ ESP swap ADD ] ifte
] "generator" set-word-prop
