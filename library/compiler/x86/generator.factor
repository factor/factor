! :folding=indent:collapseFolds=1:

! $Id$
!
! Copyright (C) 2004, 2005 Slava Pestov.
! 
! Redistribution and use in source and binary forms, with or without
! modification, are permitted provided that the following conditions are met:
! 
! 1. Redistributions of source code must retain the above copyright notice,
!    this list of conditions and the following disclaimer.
! 
! 2. Redistributions in binary form must reproduce the above copyright notice,
!    this list of conditions and the following disclaimer in the documentation
!    and/or other materials provided with the distribution.
! 
! THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES,
! INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
! FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
! DEVELOPERS AND CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
! SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
! PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
! OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
! WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
! OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
! ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

IN: compiler
USE: alien
USE: assembler
USE: inference
USE: kernel
USE: kernel-internals
USE: lists
USE: math
USE: namespaces
USE: words

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
