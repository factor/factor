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

IN: words
USE: combinators
USE: kernel
USE: lists
USE: namespaces
USE: stack
USE: strings

: vocabs ( -- list )
    #! Push a list of vocabularies.
    global [ "vocabularies" get [ vars ] bind ] bind ;

: vocab ( name -- vocab )
    #! Get a vocabulary.
    global [ "vocabularies" get get* ] bind ;

: words ( vocab -- list )
    #! Push a list of all words in a vocabulary.
    #! Filter empty slots.
    vocab [ values ] bind [ ] subset ;

: init-search-path ( -- )
    ! For files
    "scratchpad" "file-in" set
    [ "builtins" "syntax" "scratchpad" ] "file-use" set
    ! For interactive
    "scratchpad" "in" set
    [
        "user"
        "arithmetic"
        "builtins"
        "combinators"
        "compiler"
        "continuations"
        "debugger"
        "errors"
        "files"
        "hashtables"
        "inferior"
        "interpreter"
        "inspector"
        "jedit"
        "kernel"
        "listener"
        "lists"
        "logic"
        "math"
        "namespaces"
        "parser"
        "prettyprint"
        "processes"
        "profiler"
        "stack"
        "streams"
        "stdio"
        "strings"
        "syntax"
        "test"
        "threads"
        "trace"
        "unparser"
        "vectors"
        "vocabularies"
        "words"
        "scratchpad"
    ] "use" set ;
