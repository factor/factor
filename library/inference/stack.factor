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
USE: kernel
USE: lists
USE: namespaces
USE: words

\ >r [
    f \ >r dataflow, [ 1 0 node-inputs ] extend
    pop-d push-r
    [ 0 1 node-outputs ] bind
] "infer" set-word-prop

\ r> [
    f \ r> dataflow, [ 0 1 node-inputs ] extend
    pop-r push-d
    [ 1 0 node-outputs ] bind
] "infer" set-word-prop

: partial-eval ( word -- )
    #! Partially evaluate a word.
    f over dup
    "infer-effect" word-prop
    [ host-word ] with-dataflow ;

\ drop [ \ drop partial-eval ] "infer" set-word-prop
\ dup  [ \ dup  partial-eval ] "infer" set-word-prop
\ swap [ \ swap partial-eval ] "infer" set-word-prop
\ over [ \ over partial-eval ] "infer" set-word-prop
\ pick [ \ pick partial-eval ] "infer" set-word-prop
