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
USE: inference
USE: errors
USE: hashtables
USE: kernel
USE: lists
USE: logic
USE: math
USE: namespaces
USE: parser
USE: prettyprint
USE: stack
USE: stdio
USE: strings
USE: unparser
USE: vectors
USE: words

! <LittleDan> peephole?
! <LittleDan> "whose peephole are we optimizing" "your mom's"

: begin-compiling ( word -- definition )
    cell compile-aligned dup save-xt word-parameter ;

: (compile) ( word -- )
    #! Should be called inside the with-compiler scope.
    "verbose-compile" get [
        "Compiling " write dup . flush
    ] when
    begin-compiling dataflow ( optimize ) linearize generate ;

: precompile ( word -- )
    #! Print linear IR of word.
    [
        word-parameter dataflow ( optimize ) linearize [.]
    ] with-scope ;

: compile-postponed ( -- )
    compile-words get [
        uncons compile-words set (compile) compile-postponed
    ] when* ;

: compile ( word -- )
    [ postpone-word compile-postponed ] with-compiler ;

: compiled ( -- )
    #! Compile the most recently defined word.
    word compile ; parsing

: cannot-compile ( word -- )
    "verbose-compile" get [
        "Cannot compile " write .
    ] [
        drop
    ] ifte ;

: compile-all ( -- )
    #! Compile all words.
    [
        dup "infer-effect" word-property [
            [ compile ] [ [ cannot-compile ] when ] catch
        ] [
            drop
        ] ifte
    ] each-word ;
