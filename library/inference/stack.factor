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

IN: inference
USE: interpreter
USE: stack
USE: words
USE: lists

: meta-infer ( word -- )
    #! Mark a word as being partially evaluated.
    dup unit [
        car dup dataflow-word, host-word
    ] cons  "infer" set-word-property ;

\ >r [
    \ >r dataflow-word, pop-d push-r
] "infer" set-word-property
\ r> [
    \ r> dataflow-word, pop-r push-d
] "infer" set-word-property

\ drop meta-infer
\ 2drop meta-infer 
\ 3drop meta-infer
\ dup meta-infer
\ 2dup meta-infer
\ 3dup meta-infer
\ swap meta-infer
\ over meta-infer
\ pick meta-infer
\ nip meta-infer
\ tuck meta-infer
\ rot meta-infer
\ -rot meta-infer
\ 2nip meta-infer
\ transp meta-infer
\ dupd meta-infer
\ swapd meta-infer
