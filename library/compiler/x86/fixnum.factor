! :folding=indent:collapseFolds=1:

! $Id$
!
! Copyright (C) 2005 Slava Pestov.
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
USE: assembler
USE: inference
USE: math
USE: words
USE: kernel
USE: alien
USE: lists
USE: math-internals

! This file provides compiling definitions for fixnum words
! that are faster than what C gives us. There is a lot of
! code repetition here. It will be factored out at the same
! time as rewriting the code to use registers for intermediate
! values happends. At this point in time, this is just a
! prototype to test the assembler.

: self ( word -- )
    f swap dup "infer-effect" word-property (consume/produce) ;

: fixnum-insn ( overflow opcode -- )
    #! This needs to be factored.
    ECX DS>
    EAX [ ECX -4 ] MOV
    EAX [ ECX ] rot execute
    0 JNO fixup
    swap compile-call
    0 JMP fixup >r
    compiled-offset swap patch
    ECX 4 SUB
    [ ECX ] EAX MOV
    ECX >DS
    r> compiled-offset swap patch ;

\ fixnum+ [
    drop \ fixnum+ \ ADD fixnum-insn
] "generator" set-word-property

\ fixnum+ [ \ fixnum+ self ] "infer" set-word-property

\ fixnum- [
    drop \ fixnum- \ SUB fixnum-insn
] "generator" set-word-property

\ fixnum- [ \ fixnum- self ] "infer" set-word-property

\ fixnum* [
    drop
    ECX DS>
    EAX [ ECX -4 ] MOV
    EAX 3 SHR
    EAX [ ECX ] IMUL
    0 JNO fixup
    \ fixnum* compile-call
    0 JMP fixup >r
    compiled-offset swap patch
    ECX 4 SUB
    [ ECX ] EAX MOV
    ECX >DS
    r> compiled-offset swap patch
] "generator" set-word-property

\ fixnum* [ \ fixnum* self ] "infer" set-word-property

\ fixnum/i [
    drop
    ECX DS>
    EAX [ ECX -4 ] MOV
    CDQ
    [ ECX ] IDIV
    EAX 3 SHL
    0 JNO fixup
    \ fixnum/i compile-call
    0 JMP fixup >r
    compiled-offset swap patch
    ECX 4 SUB
    [ ECX ] EAX MOV
    ECX >DS
    r> compiled-offset swap patch
] "generator" set-word-property

\ fixnum/i [ \ fixnum/i self ] "infer" set-word-property

\ fixnum-mod [
    drop
    ECX DS>
    EAX [ ECX -4 ] MOV
    CDQ
    [ ECX ] IDIV
    EAX 3 SHL
    0 JNO fixup
    \ fixnum/i compile-call
    0 JMP fixup >r
    compiled-offset swap patch
    ECX 4 SUB
    [ ECX ] EDX MOV
    ECX >DS
    r> compiled-offset swap patch
] "generator" set-word-property

\ fixnum-mod [ \ fixnum-mod self ] "infer" set-word-property

\ fixnum/mod [
    drop
    ECX DS>
    EAX [ ECX -4 ] MOV
    CDQ
    [ ECX ] IDIV
    EAX 3 SHL
    0 JNO fixup
    \ fixnum/i compile-call
    0 JMP fixup >r
    compiled-offset swap patch
    [ ECX -4 ] EAX MOV
    [ ECX ] EDX MOV
    ECX >DS
    r> compiled-offset swap patch
] "generator" set-word-property

\ fixnum/mod [ \ fixnum/mod self ] "infer" set-word-property
