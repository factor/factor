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
USE: combinators
USE: errors
USE: kernel
USE: lists
USE: logic
USE: math
USE: namespaces
USE: parser
USE: stack
USE: strings
USE: unparser
USE: vectors
USE: words

: pop-literal ( -- obj )
    "compile-datastack" get vector-pop ;

: immediate? ( obj -- ? )
    #! fixnums and f have a pointerless representation, and
    #! are compiled immediately. Everything else can be moved
    #! by GC, and is indexed through a table.
    dup fixnum? swap f eq? or ;

: compile-literal ( obj -- )
    dup immediate? [
        address LITERAL
    ] [
        intern-literal [LITERAL]
    ] ifte ;

: commit-literals ( -- )
    "compile-datastack" get
    dup vector-empty? [
        drop
    ] [
        dup [ compile-literal ] vector-each
        0 swap set-vector-length
    ] ifte ;

: postpone ( obj -- )
    #! Literals are not compiled immediately, so that words like
    #! ifte with special compilation behavior can work.
    "compile-datastack" get vector-push ;

: tail? ( -- ? )
    "compile-callstack" get vector-empty? ;

: compiled-xt ( word -- xt )
    "compiled-xt" over word-property dup [
        nip
    ] [
        drop word-xt
    ] ifte ;

: compile-simple-word ( word -- )
    #! Compile a JMP at the end (tail call optimization)
    commit-literals compiled-xt
    tail? [ JUMP ] [ CALL ] ifte drop ;

: compile-word ( word -- )
    #! If a word has a compiling property, then it has special
    #! compilation behavior.
    "compiling" over word-property dup [
        nip call
    ] [
        drop compile-simple-word
    ] ifte ;

: begin-compiling-quot ( quot -- )
    "compile-callstack" get vector-push ;

: end-compiling-quot ( -- )
    "compile-callstack" get vector-pop drop ;

: compiling ( quot -- )
    #! Called on each iteration of compile-loop, with the
    #! remaining quotation.
    [
        "compile-callstack" get
        dup vector-length pred
        swap set-vector-nth
    ] [
        end-compiling-quot
    ] ifte* ;

: compile-atom ( obj -- )
    dup word? [ compile-word ] [ postpone ] ifte ;

: compile-loop ( quot -- )
    [
        uncons  dup compiling  swap compile-atom  compile-loop
    ] when* ;

: compile-quot ( quot -- )
    [
        dup begin-compiling-quot compile-loop commit-literals
    ] when* ;

: with-compiler ( quot -- )
    [
        10 <vector> "compile-datastack" set
        10 <vector> "compile-callstack" set
        call
    ] with-scope ;

: begin-compiling ( word -- )
    cell compile-aligned
    compiled-offset "compiled-xt" rot set-word-property ;

: end-compiling ( word -- xt )
    "compiled-xt" over word-property over set-word-xt
    f "compiled-xt" rot set-word-property ;

: compile ( word -- )
    intern dup
    begin-compiling
    dup word-parameter [ compile-quot RET ] with-compiler
    end-compiling ;

: compiled word compile ; parsing
