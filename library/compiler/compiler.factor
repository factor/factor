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
USE: math
USE: stack
USE: lists
USE: combinators
USE: words
USE: namespaces
USE: unparser
USE: errors
USE: strings
USE: logic
USE: kernel
USE: vectors

: compile-word ( word -- )
    #! Compile a JMP at the end (tail call optimization)
    word-xt "compile-last" get [ JMP ] [ CALL ] ifte ;

: compile-literal ( obj -- )
    dup fixnum? [
        address-of LITERAL
    ] [
        intern-literal [LITERAL]
    ] ifte ;

: commit-literals ( -- )
    "compile-datastack" get dup [ compile-literal ] vector-each
    0 swap set-vector-length ;

: postpone ( obj -- )
    "compile-datastack" get vector-push ;

: compile-atom ( obj -- )
    [
        [ word? ] [ commit-literals compile-word ]
        [ drop t ] [ postpone ]
    ] cond ;

: compile-loop ( quot -- )
    dup [
        unswons
        over not "compile-last" set
        compile-atom
        compile-loop
    ] [
        commit-literals drop RET
    ] ifte ;

: compile-quot ( quot -- xt )
    [
        "compile-last" off
        10 <vector> "compile-datastack" set
        compiled-offset swap compile-loop
    ] with-scope ;

: compile ( word -- )
    intern dup word-parameter compile-quot swap set-word-xt ;

: call-xt ( xt -- )
    #! For testing.
    0 f f <word> [ set-word-xt ] keep execute ;
