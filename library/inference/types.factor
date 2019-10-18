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
USE: errors
USE: generic
USE: interpreter
USE: kernel
USE: kernel-internals
USE: lists
USE: math
USE: namespaces
USE: strings
USE: vectors
USE: words
USE: stdio
USE: prettyprint

! Enhanced inference of primitives relating to data types.
! Optimizes type checks and slot access.

: infer-check ( assert class -- )
    peek-d dup value-class pick = [
        3drop
    ] [
        value-class-and
        dup "infer-effect" word-property consume/produce
    ] ifte ;

\ >cons [
    \ >cons \ cons infer-check
] "infer" set-word-property

\ >vector [
    \ >vector \ vector infer-check
] "infer" set-word-property

\ >string [
    \ >string \ string infer-check
] "infer" set-word-property

\ slot [
    [ object fixnum ] ensure-d
    dataflow-drop, pop-d literal-value
    peek-d value-class builtin-supertypes dup length 1 = [
        cons #slot dataflow, [
            1 0 node-inputs
            [ object ] consume-d
            [ object ] produce-d
            1 0 node-outputs
        ] bind
    ] [
        "slot called without static type knowledge" throw
    ] ifte
] "infer" set-word-property

: type-value-map ( value -- )
    [
        num-types [
            dup builtin-type dup [
                pick swons cons ,
            ] [
                2drop
            ] ifte
        ] times*
    ] make-list nip ;

\ type [
    [ object ] ensure-d
    \ type #call dataflow, [
        peek-d type-value-map >r
        1 0 node-inputs
        [ object ] consume-d
        [ fixnum ] produce-d
        r> peek-d [ type-propagations set ] bind
        1 0 node-outputs
    ] bind
] "infer" set-word-property
