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
USE: namespaces

\ >r [
    f #>r dataflow, [ 1 0 node-inputs ] extend
    pop-d push-r
    [ 0 1 node-outputs ] bind
] "infer" set-word-property

\ >r t "shuffle" set-word-property

\ r> [
    f #r> dataflow, [ 0 1 node-inputs ] extend
    pop-r push-d
    [ 1 0 node-outputs ] bind
] "infer" set-word-property

\ r> t "shuffle" set-word-property

: meta-infer ( word op -- )
    #! Mark a word as being partially evaluated.
    dup t "shuffle" set-word-property
    dupd [
        over unit , \ car ,
        f , ,
        "infer-effect" word-property ,
        [ drop host-word ] ,
        \ with-dataflow ,
    ] make-list "infer" set-word-property ;

\ drop #drop meta-infer
\ dup #dup meta-infer
\ swap #swap meta-infer
\ over #over meta-infer
\ pick #pick meta-infer
\ nip #nip meta-infer
\ tuck #tuck meta-infer
\ rot #rot meta-infer
