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

: tab-size
    #! Change this to suit your tastes.
    4 ;

: prettyprint-indent ( indent -- )
    #! Print the given number of spaces.
    spaces write ;

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

: prettyprint-[] ( indent list -- indent )
    swap prettyprint-[ swap prettyprint-list prettyprint-] ;

: prettyprint-: ( indent -- indent )
    ":" write prettyprint-space
    tab-size + ;

: prettyprint-; ( indent -- indent )
    ";" write
    tab-size - ;

: prettyprint-inline ( worddef -- )
    word-of-worddef [ $inline ] bind [
        " inline" write
    ] when ;

: prettyprint-:; ( indent list -- indent )
    swap prettyprint-: swap prettyprint-list prettyprint-; ;

: prettyprint-~<< ( indent -- indent )
    "~<<" write prettyprint-space
    tab-size + ;

: prettyprint->>~ ( indent -- indent )
    ">>~" write
    tab-size - dup prettyprint-newline ;

: prettyprint-~<<>>~ ( indent list -- indent )
    swap prettyprint-~<< swap prettyprint-list prettyprint->>~ ;

: word-or-comment? ( obj -- ? )
    [ word? ] [ comment? ] cleave or ;

: prettyprint-object ( indent obj -- indent )
    dup word-or-comment? [
        dup >str ends-with-newline? [
            write dup prettyprint-indent
        ] [
            unparse. " " write
        ] ifte
    ] [
        unparse. " " write
    ] ifte ;

: prettyprint-list ( indent list -- indent )
    #! Pretty-print a list, without [ and ].
    [ prettyprint* ] each ;

: compound-or-compiled? ( worddef -- ? )
    dup compiled? swap compound? or ;

: prettyprint* ( indent obj -- indent )
    [
        [ not       ] [ prettyprint-object ]
        [ list?     ] [ prettyprint-[] ]
        [ compound-or-compiled? ] [
            tuck worddef>list
            prettyprint-:;
            swap prettyprint-inline
            dup prettyprint-newline
        ]
        [ shuffle?  ] [ worddef>list prettyprint-~<<>>~ ]
        [ drop t    ] [ prettyprint-object ]
    ] cond ;

: prettyprint ( list -- )
    0 swap prettyprint* drop ;

: see ( word -- )
    worddef prettyprint ;
