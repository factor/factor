! :folding=indent:collapseFolds=1:

! $Id$
!
! Copyright (C) 2004 Slava Pestov.
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
USE: inference
USE: kernel
USE: namespaces
USE: words
USE: lists
USE: math

: DS ( -- address ) "ds" dlsym-self ;

: absolute-ds ( -- )
    #! Add an entry to the relocation table for the 32-bit
    #! immediate just compiled.
    "ds" f rel-dlsym-self ;

: POP-DS ( -- )
    #! Pop datastack to EAX.
    DS ECX [I]>R  absolute-ds
    ECX EAX [R]>R
    4 ECX R-I
    ECX DS R>[I]  absolute-ds ;

#push-immediate [
    DS ECX [I]>R  absolute-ds
    4 ECX R+I
    address  ECX I>[R]
    ECX DS R>[I]  absolute-ds
] "generator" set-word-property

#push-indirect [
    DS ECX [I]>R  absolute-ds
    4 ECX R+I
    intern-literal EAX [I]>R  rel-address
    EAX ECX R>[R]
    ECX DS R>[I]  absolute-ds
] "generator" set-word-property

#replace-immediate [
    DS ECX [I]>R  absolute-ds
    address  ECX I>[R]
    ECX DS R>[I]  absolute-ds
] "generator" set-word-property

#replace-indirect [
    DS ECX [I]>R  absolute-ds
    intern-literal EAX [I]>R  rel-address
    EAX ECX R>[R]
    ECX DS R>[I]  absolute-ds
] "generator" set-word-property

#call [
    dup dup postpone-word
    CALL compiled-offset defer-xt
    t rel-word
] "generator" set-word-property

#jump [
    dup dup postpone-word
    JUMP compiled-offset defer-xt
    t rel-word
] "generator" set-word-property

#call-label [
    CALL compiled-offset defer-xt
] "generator" set-word-property

#jump-label [
    JUMP compiled-offset defer-xt
] "generator" set-word-property

#jump-t [
    POP-DS
    ! condition is now in EAX
    f address EAX CMP-I-R
    ! jump w/ address added later
    JNE compiled-offset defer-xt
] "generator" set-word-property

#return-to [
    PUSH-I/PARTIAL 0 defer-xt rel-address
] "generator" set-word-property

#return [ drop RET ] "generator" set-word-property

#dispatch [
    #! Compile a piece of code that jumps to an offset in a
    #! jump table indexed by the fixnum at the top of the stack.
    #! The jump table must immediately follow this macro.
    drop
    POP-DS
    1 EAX R>>I
    EAX+/PARTIAL ( -- fixup ) rel-address
    EAX JUMP-[R]
    compile-aligned
    compiled-offset swap set-compiled-cell ( fixup -- )
] "generator" set-word-property

#target [
    #! Jump table entries are absolute addresses.
    compiled-offset 0 compile-cell 0 defer-xt rel-address
] "generator" set-word-property

#c-call [
    uncons alien-symbol CALL JUMP-FIXUP
] "generator" set-word-property

#unbox [
    dlsym-self CALL JUMP-FIXUP
    EAX PUSH-R
] "generator" set-word-property

#box [
    EAX PUSH-R
    dlsym-self CALL JUMP-FIXUP
    4 ESP R+I
] "generator" set-word-property

#cleanup [
    dup 0 = [ drop ] [ ESP R+I ] ifte
] "generator" set-word-property

[
    [ #drop drop ]
    [ #dup  dup  ]
    [ #swap swap ]
    [ #over over ]
    [ #pick pick ]
    [ #>r   >r   ]
    [ #r>   r>   ]
] [
    uncons
    [
        car dup CALL compiled-offset defer-xt t rel-word drop
    ] cons
    "generator" set-word-property
] each
