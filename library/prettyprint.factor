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
USE: arithmetic
USE: combinators
USE: errors
USE: format
USE: kernel
USE: logic
USE: lists
USE: namespaces
USE: prettyprint
USE: stack
USE: stdio
USE: strings
USE: styles
USE: unparser
USE: vectors
USE: words

: tab-size
    #! Change this to suit your tastes.
    4 ;

: prettyprint-limit ( -- limit )
    #! Avoid infinite loops -- maximum indent, 10 levels.
    "prettyprint-limit" get [ 40 ] unless* ;

: prettyprint-indent ( indent -- )
    #! Print the given number of spaces.
    " " fill write ;

: prettyprint-newline ( indent -- )
    "\n" write prettyprint-indent ;

: prettyprint-space ( -- )
    " " write ;

: newline-after? ( obj -- ? )
    comment? ;

! Real definition follows
DEFER: prettyprint*

: prettyprint-element ( indent obj -- indent )
    dup >r prettyprint* r> newline-after? [
        dup prettyprint-newline
    ] [
        prettyprint-space
    ] ifte ;

: <prettyprint ( indent -- indent )
    tab-size +
    "prettyprint-single-line" get [
        prettyprint-space
    ] [
        dup prettyprint-newline
    ] ifte ;

: prettyprint> ( indent -- indent )
    tab-size -
    "prettyprint-single-line" get [
        dup prettyprint-newline
    ] unless ;

: check-recursion ( indent obj quot -- )
    >r over prettyprint-limit >= [
        r> drop drop "#< ... > " write
    ] [
        r> call
    ] ifte ;

: prettyprint-[ ( indent -- indent )
    "[" write <prettyprint ;

: prettyprint-] ( indent -- indent )
    prettyprint> "]" write ;

: (prettyprint-list) ( indent list -- indent )
    [
        uncons >r prettyprint-element r>
        dup cons? [
            (prettyprint-list)
        ] [
            [
                "|" write prettyprint-space prettyprint-element
            ] when*
        ] ifte
    ] when* ;

: prettyprint-list ( indent list -- indent )
    #! Pretty-print a list, without [ and ].
    [ (prettyprint-list) ] check-recursion ;

: prettyprint-[] ( indent list -- indent )
    swap prettyprint-[ swap prettyprint-list prettyprint-] ;

: prettyprint-{ ( indent -- indent )
    "{" write <prettyprint ;

: prettyprint-} ( indent -- indent )
    prettyprint> "}" write ;

: prettyprint-vector ( indent list -- indent )
    #! Pretty-print a vector, without { and }.
    [ [ prettyprint-element ] vector-each ] check-recursion ;

: prettyprint-{} ( indent list -- indent )
    swap prettyprint-{ swap prettyprint-vector prettyprint-} ;

: trim-newline ( str -- str )
    dup ends-with-newline? dup [ nip ] [ drop ] ifte ;

: prettyprint-comment ( comment -- )
    [ "comments" ] get-style [ trim-newline write-attr ] bind ;

: word-link ( word -- link )
    <%
    "vocabularies'" %
    dup word-vocabulary %
    "'" %
    word-name %
    %> ;

: word-attrs ( word -- attrs )
    dup word-style clone swap
    dup defined? [
        swap [ word-link "link" set ] extend
    ] [
        drop
    ] ifte ;

: prettyprint-word ( word -- )
    dup word-attrs [ word-name write-attr ] bind ;

: prettyprint-object ( indent obj -- indent )
    unparse write ;

: prettyprint* ( indent obj -- indent )
    [
        [ f =       ] [ prettyprint-object ]
        [ cons?     ] [ prettyprint-[] ]
        [ vector?   ] [ prettyprint-{} ]
        [ comment?  ] [ prettyprint-comment ]
        [ word?     ] [ prettyprint-word ]
        [ drop t    ] [ prettyprint-object ]
    ] cond ;

: prettyprint ( obj -- )
    0 swap prettyprint* drop terpri ;

: vocab-link ( vocab -- link )
    <% "vocabularies'" % % %> ;

: vocab-attrs ( word -- attrs )
    default-style clone [ vocab-link "link" set ] extend ;

: prettyprint-vocab ( vocab -- )
    dup vocab-attrs [ write-attr ] bind ;

: prettyprint-IN: ( indent word -- indent )
    "IN:" write prettyprint-space
    word-vocabulary prettyprint-vocab
    dup prettyprint-newline ;

: prettyprint-: ( indent -- indent )
    ":" write prettyprint-space
    tab-size + ;

: prettyprint-; ( indent -- indent )
    ";" write
    tab-size - ;

: prettyprint-plist ( word -- )
    "parsing" over word-property [ " parsing" write ] when
    "inline" over word-property [ " inline" write ] when
    drop ;

: prettyprint-:; ( indent word list -- indent )
    over >r >r dup
    >r prettyprint-IN: prettyprint-: r>
    prettyprint-word
    native? [ dup prettyprint-newline ] [ prettyprint-space ] ifte
    r>
    prettyprint-list prettyprint-; r> prettyprint-plist ;

: . ( obj -- )
    [
        "prettyprint-single-line" on
        tab-size 4 * "prettyprint-limit" set
        prettyprint
    ] with-scope ;

: [.] ( list -- )
    #! Unparse each element on its own line.
    [ . ] each ;

: .n namestack  . ;
: .s datastack  . ;
: .r callstack  . ;
: .c catchstack . ;
