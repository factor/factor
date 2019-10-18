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

IN: words
USE: hashtables
USE: kernel
USE: lists
USE: namespaces
USE: strings

: word ( -- word ) global [ "last-word" get ] bind ;
: set-word ( word -- ) global [ "last-word" set ] bind ;

: vocabs ( -- list )
    #! Push a list of vocabularies.
    vocabularies get hash-keys [ str-lexi> ] sort ;

: vocab ( name -- vocab )
    #! Get a vocabulary.
    vocabularies get hash ;

: word-sort ( list -- list )
    #! Sort a list of words by name.
    [ swap word-name swap word-name str-lexi> ] sort ;

: words ( vocab -- list )
    #! Push a list of all words in a vocabulary.
    #! Filter empty slots.
    vocab dup [ hash-values [ ] subset word-sort ] when ;

: each-word ( quot -- )
    #! Apply a quotation to each word in the image.
    vocabs [ words [ swap dup >r call r> ] each ] each drop ;
    inline

: (search) ( name vocab -- word )
    vocab dup [ hash ] [ 2drop f ] ifte ;

: search ( name list -- word )
    #! Search for a word in a list of vocabularies.
    dup [
        2dup car (search) dup [
            nip nip ( found )
        ] [
            drop cdr search ( check next )
        ] ifte
    ] [
        2drop f ( not found )
    ] ifte ;

: <plist> ( name vocab -- plist )
    "vocabulary" swons swap "name" swons 2list ;

: (create) ( name vocab -- word )
    #! Create an undefined word without adding to a vocabulary.
    <plist> <word> [ set-word-plist ] keep ;

: reveal ( word -- )
    #! Add a new word to its vocabulary.
    vocabularies get [
        dup word-vocabulary nest [
            dup word-name set
        ] bind
    ] bind ;

: create ( name vocab -- word )
    #! Create a new word in a vocabulary. If the vocabulary
    #! already contains the word, the existing instance is
    #! returned.
    2dup (search) [ nip nip ] [ (create) dup reveal ] ifte* ;

: forget ( word -- )
    #! Remove a word definition.
    dup word-vocabulary vocab [ word-name off ] bind ;

: init-search-path ( -- )
    ! For files
    "scratchpad" "file-in" set
    [ "syntax" "scratchpad" ] "file-use" set
    ! For interactive
    "scratchpad" "in" set
    [
        "compiler"
        "debugger"
        "errors"
        "files"
        "generic"
        "hashtables"
        "inference"
        "interpreter"
        "jedit"
        "kernel"
        "listener"
        "lists"
        "math"
        "namespaces"
        "parser"
        "prettyprint"
        "processes"
        "profiler"
        "streams"
        "stdio"
        "strings"
        "syntax"
        "test"
        "threads"
        "unparser"
        "vectors"
        "words"
        "scratchpad"
    ] "use" set ;
