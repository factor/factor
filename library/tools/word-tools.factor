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
USE: inspector
USE: lists
USE: kernel
USE: namespaces
USE: prettyprint
USE: stack
USE: stdio
USE: strings
USE: unparser

: word-uses? ( of in -- ? )
    2dup = [
        2drop f ! Don't say that a word uses itself
    ] [
        word-parameter tree-contains?
    ] ifte ;

: usages-in-vocab ( of vocab -- usages )
    #! Push a list of all usages of a word in a vocabulary.
    words [
        dup compound? [
            dupd word-uses?
        ] [
            drop f ! Ignore words without a definition
        ] ifte
    ] subset nip ;

: usages-in-vocab. ( of vocab -- )
    #! List all usages of a word in a vocabulary.
    tuck usages-in-vocab dup [
        swap "IN: " write print [.]
    ] [
        2drop
    ] ifte ;

: usages. ( word -- )
    #! List all usages of a word in all vocabularies.
    vocabs [ dupd usages-in-vocab. ] each drop ;

: vocab-apropos ( substring vocab -- list )
    #! Push a list of all words in a vocabulary whose names
    #! contain a string.
    words [ word-name dupd str-contains? ] subset nip ;

: vocab-apropos. ( substring vocab -- )
    #! List all words in a vocabulary that contain a string.
    tuck vocab-apropos dup [
        "IN: " write swap print [.]
    ] [
        2drop
    ] ifte ;

: vocab-completions ( substring vocab -- list )
    #! Used by jEdit plugin. Like vocab-apropos, but only
    #! matches at the start of a word name are considered.
    words [ word-name over str-head? ] subset nip ;

: apropos. ( substring -- )
    #! List all words that contain a string.
    vocabs [ dupd vocab-apropos. ] each drop ;

: in. ( -- )
    #! Print the vocabulary where new words are added in
    #! interactive parsers.
    "in" get print ;

: use. ( -- )
    #! Print the vocabulary search path for interactive parsers.
    "use" get . ;

: vocabs. ( -- )
    vocabs . ;

: words. ( vocab -- )
    words . ;
