! :folding=indent:collapseFolds=1:

! $Id$
!
! Copyright (C) 2003, 2004 Slava Pestov.
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

IN: init
USE: combinators
USE: compiler
USE: continuations
USE: errors
USE: interpreter
USE: kernel
USE: lists
USE: namespaces
USE: parser
USE: stack
USE: stdio
USE: streams
USE: strings

! This file is run as the last stage of boot.factor; it relies
! on all other words already being defined.

: init-search-path ( -- )
    #! Sets up the default vocabularies.
    [
        "user" ! This is first
        "arithmetic"
        "builtins"
        "combinators"
        "compiler"
        "errors"
        "debugger"
        "hashtables"
        "inspector"
        "interpreter"
        "kernel"
        "lists"
        "logic"
        "math"
        "namespaces"
        "parser"
        "prettyprint"
        "stack"
        "stdio"
        "strings"
        "test"
        "trace"
        "unparser"
        "vectors"
        "vocabularies"
        "words"
        "scratchpad" ! This is last
    ] "use" set
    ! New words go in 'user' vocabulary.
    "user" "in" set ;

: init-scratchpad ( -- )
    #! The contents of the scratchpad vocabulary is not saved
    #! between runs.
    <namespace> "scratchpad" "vocabularies" get set* ;

: init-interpreter ( -- )
    #! If we're run stand-alone, start the interpreter on stdio.
    "interactive" get [
        [ "top-level-continuation" set ] callcc0

        interpreter-loop
    ] [
        f "top-level-continuation" set
    ] ifte ;
