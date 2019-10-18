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

IN: prettyprint
USE: generic
USE: kernel
USE: lists
USE: math
USE: stdio
USE: strings
USE: presentation
USE: unparser
USE: words

! Prettyprinting words
: vocab-attrs ( word -- attrs )
    vocab-link "object-link" default-style acons ;

: prettyprint-vocab ( vocab -- )
    dup vocab-attrs write-attr ;

: prettyprint-IN: ( indent word -- )
    \ IN: prettyprint* prettyprint-space
    word-vocabulary prettyprint-vocab prettyprint-newline ;

: prettyprint-: ( indent -- indent )
    \ : prettyprint* prettyprint-space
    tab-size + ;

: prettyprint-; ( indent -- indent )
    \ ; prettyprint*
    tab-size - ;

: prettyprint-prop ( word prop -- )
    tuck word-name word-property [
        prettyprint-space prettyprint-1
    ] [
        drop
    ] ifte ;

: prettyprint-plist ( word -- )
    dup
    \ parsing prettyprint-prop
    \ inline prettyprint-prop ;

: prettyprint-comment ( comment -- )
    "comments" style write-attr ;

: stack-effect. ( word -- )
    stack-effect [
        " " write
        [ CHAR: ( , , CHAR: ) , ] make-string prettyprint-comment
    ] when* ;

: documentation. ( indent word -- indent )
    documentation [
        "\n" split [
            "#!" swap cat2 prettyprint-comment
            dup prettyprint-newline
        ] each
    ] when* ;

: prettyprint-docs ( indent word -- indent )
    [
        stack-effect. dup prettyprint-newline
    ] keep documentation. ;

GENERIC: see ( word -- )

M: object see ( obj -- )
    "Not a word: " write . ;

M: compound see ( word -- )
    0 swap
    [ dupd prettyprint-IN: prettyprint-: ] keep
    [ prettyprint-1 ] keep
    [ prettyprint-docs ] keep
    [ word-parameter prettyprint-list prettyprint-; ] keep
    prettyprint-plist prettyprint-newline ;

M: primitive see ( word -- )
    "PRIMITIVE: " write dup unparse write stack-effect. terpri ;

M: symbol see ( word -- )
    0 over prettyprint-IN:
    \ SYMBOL: prettyprint-1 prettyprint-space . ;

M: undefined see ( word -- )
    drop "Not defined" print ;
