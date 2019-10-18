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
: vocab-actions ( search -- list )
    [
        [ "Words"   | "words."        ]
        [ "Use"     | "\"use\" cons@" ]
        [ "In"      | "\"in\" set" ]
    ] ;

: vocab-attrs ( vocab -- attrs )
    #! Words without a vocabulary do not get a link or an action
    #! popup.
    unparse vocab-actions <actions> "actions" swons unit ;

: prettyprint-vocab ( vocab -- )
    dup vocab-attrs write-attr ;

: prettyprint-IN: ( word -- )
    \ IN: prettyprint* " " write
    word-vocabulary prettyprint-vocab " " write ;

: prettyprint-: ( indent -- indent )
    \ : prettyprint* " " write
    tab-size + ;

: prettyprint-; ( indent -- indent )
    \ ; prettyprint*
    tab-size - ;

: prettyprint-prop ( word prop -- )
    tuck word-name word-property [
        " " write prettyprint-1
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

: prettyprint-M: ( indent -- indent )
    \ M: prettyprint-1 " " write tab-size + ;

GENERIC: see ( word -- )

M: compound see ( word -- )
    dup prettyprint-IN:
    0 prettyprint-: swap
    [ prettyprint-1 ] keep
    [ prettyprint-docs ] keep
    [ word-parameter prettyprint-list prettyprint-; ] keep
    prettyprint-plist prettyprint-newline ;

: see-method ( indent word class method -- indent )
    >r >r >r prettyprint-M:
    r> r> prettyprint-1 " " write
    prettyprint-1 " " write
    dup prettyprint-newline
    r> prettyprint-list
    prettyprint-;
    terpri ;

M: generic see ( word -- )
    dup prettyprint-IN:
    0 swap
    dup "definer" word-property prettyprint-1 " " write
    dup prettyprint-1 terpri
    dup methods [ over >r uncons see-method r> ] each 2drop ;

M: primitive see ( word -- )
    dup prettyprint-IN:
    "PRIMITIVE: " write dup prettyprint-1 stack-effect. terpri ;

M: symbol see ( word -- )
    dup prettyprint-IN:
    \ SYMBOL: prettyprint-1 " " write . ;

M: undefined see ( word -- )
    dup prettyprint-IN:
    \ DEFER: prettyprint-1 " " write . ;
