!:folding=indent:collapseFolds=1:

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
USE: vocabularies
USE: words

: tab-size
    #! Change this to suit your tastes.
    4 ;

: prettyprint-indent ( indent -- )
    #! Print the given number of spaces.
    " " fill write ;

: prettyprint-newline ( indent -- )
    "\n" write prettyprint-indent ;

: prettyprint-space ( -- )
    " " write ;

: prettyprint-[ ( indent -- indent )
    "[" write
    tab-size + dup prettyprint-newline ;

: prettyprint-] ( indent -- indent )
    tab-size - dup prettyprint-newline
    "]" write
    prettyprint-space ;

! Real definition follows
DEFER: prettyprint*

: prettyprint-list ( indent list -- indent )
    #! Pretty-print a list, without [ and ].
    [ prettyprint* ] each ;

: prettyprint-[] ( indent list -- indent )
    swap prettyprint-[ swap prettyprint-list prettyprint-] ;

: write-comment ( comment -- )
    [ "comments" ] get-style [ write-attr ] bind ;

: prettyprint-comment ( indent obj -- indent )
    ends-with-newline? dup [
        write-comment terpri
        dup prettyprint-indent
    ] [
        drop write-comment " " write
    ] ifte ;

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
    dup word-attrs [ word-name write-attr ] bind " " write ;

: prettyprint-object ( indent obj -- indent )
    unparse write " " write ;

: prettyprint* ( indent obj -- indent )
    [
        [ not       ] [ prettyprint-object ]
        [ list?     ] [ prettyprint-[] ]
        [ comment?  ] [ prettyprint-comment ]
        [ word?     ] [ prettyprint-word ]
        [ drop t    ] [ prettyprint-object ]
    ] cond ;

: prettyprint ( list -- )
    0 swap prettyprint* drop ;

: prettyprint-: ( indent -- indent )
    ":" write prettyprint-space
    tab-size + ;

: prettyprint-; ( indent -- indent )
    ";" write
    tab-size - ;

: prettyprint-:; ( indent word list -- indent )
    [ [ prettyprint-: ] dip prettyprint-word ] dip
    prettyprint-list prettyprint-; ;
