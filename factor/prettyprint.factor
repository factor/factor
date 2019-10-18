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

4 @indent

: <prettyprint-token> ( string -- token )
    dup <namespace> [
        @name
        t @prettyprint-token
    ] extend tuck s@ ;

: prettyprint-token? ( token -- token? )
    dup has-namespace? [
        [ $prettyprint-token ] bind
    ] [
        drop f
    ] ifte ;

: prettyprint-indent ( indent -- indent )
    dup spaces write ;

: prettyprint-newline/space ( indent ? -- indent )
    [ "\n" write prettyprint-indent ] [ " " write ] ifte ;

: prettyprint-indent-params ( indent obj -- indent ? ? name )
    [
        $indent+ [ $indent + ] when
        $indent- [ $indent - ] when
        $-indent [ $indent - t ] [ f ] ifte
        $newline
        $name
    ] bind ;

: prettyprint-token ( indent obj -- indent )
    prettyprint-indent-params
    [
        [
            "\n" write
            prettyprint-indent
        ] when
    ] 2dip
    write prettyprint-newline/space ;

: prettyprint-unparsed ( indent unparse -- indent )
    dup "\n" = [
        drop "\n" write prettyprint-indent
    ] [
        write " " write
    ] ifte ;

: [prettyprint-tty] ( indent obj -- indent )
    dup prettyprint-token? [
        prettyprint-token
    ] [
        unparse prettyprint-unparsed
    ] ifte ;

: prettyprint-html-unparse ( obj -- unparse )
    dup unparse dup "\n" = [
        nip
    ] [
        swap word? [
            "<a href=\"see.lhtml?" swap "\">" over "</a>" cat5
        ] [
            chars>entities
        ] ifte
    ] ifte ;

: [prettyprint-html] ( indent obj -- indent )
    dup prettyprint-token? [
        prettyprint-token
    ] [
        prettyprint-html-unparse prettyprint-unparsed
    ] ifte ;

: prettyprint-list* ( quot list -- )
    ! Pretty-print a list, without [ and ].
    [
        over [
            prettyprint*
        ] dip
    ] each
    ! Drop the quotation
    drop ;

: prettyprint-list ( quot list before after -- )
    ! Apply the quotation to 'before', call prettyprint* on
    ! 'list', and apply the quotation to 'after'.
    swapd [
        [
            swap dup [
                call
            ] dip
        ] dip
        swap dup [
            swap prettyprint-list*
        ] dip
    ] dip
    swap call ;

: prettyprint* ( quot obj -- )
    [
        [ not       ] [ swap call ]
        [ list?     ] [ $[ $] prettyprint-list ]
        [ compound? ] [ worddef>list $: $; prettyprint-list ]
        [ compiled? ] [ worddef>list $: $; prettyprint-list ]
        [ shuffle?  ] [ worddef>list $~<< $>>~ prettyprint-list ]
        [ drop t    ] [ swap call ]
    ] cond ;

: prettyprint-tty ( list -- )
    0 [ [prettyprint-tty] ] rot prettyprint* drop ;

: prettyprint-html ( list -- )
    0 [ [prettyprint-html] ] rot prettyprint* drop ;

: see ( word -- )
    worddef prettyprint-tty ;

: see/html ( word -- )
    "<pre>" print
    worddef prettyprint-html
    "</pre>" print ;

!!!

"["   <prettyprint-token> [
    t @indent+
    t @newline
] bind

"]"   <prettyprint-token> [
    t @-indent
] bind

":"   <prettyprint-token> [
    t @indent+
] bind

";"   <prettyprint-token> [
    t @indent-
    t @newline
] bind

"~<<" <prettyprint-token> [
    t @indent+
] bind

">>~" <prettyprint-token> [
    t @indent-
    t @newline
] bind
