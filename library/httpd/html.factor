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

IN: html
USE: combinators
USE: format
USE: lists
USE: logic
USE: kernel
USE: namespaces
USE: stack
USE: stdio
USE: streams
USE: strings
USE: unparser
USE: url-encoding

: html-entities ( -- alist )
    [
        [ CHAR: < | "&lt;"   ]
        [ CHAR: > | "&gt;"   ]
        [ CHAR: & | "&amp;"  ]
        [ CHAR: ' | "&apos;" ]
        [ CHAR: " | "&quot;" ]
    ] ;

: char>entity ( ch -- str )
    dup >r html-entities assoc dup r> ? ;

: chars>entities ( str -- str )
    #! Convert <, >, &, ' and " to HTML entities.
    [ dup html-entities assoc dup rot ? ] str-map ;

: >hex-color ( triplet -- hex )
    [ >hex 2 digits ] map "#" swons cat ;

: fg-css% ( color -- )
    "color: " % >hex-color % "; " % ;

: bold-css% ( flag -- )
    [ "font-weight: bold; " % ] when ;

: italics-css% ( flag -- )
    [ "font-style: italic; " % ] when ;

: underline-css% ( flag -- )
    [ "text-decoration: underline; " % ] when ;

: size-css% ( size -- )
    "font-size: " % unparse % "; " % ;

: font-css% ( font -- )
    "font-family: " % % "; " % ;

: css-style ( style -- )
    <% [
        [ "fg"        fg-css% ]
        [ "bold"      bold-css% ]
        [ "italics"   italics-css% ]
        [ "underline" underline-css% ]
        [ "size"      size-css% ]
        [ "font"      font-css% ]
    ] assoc-apply %> ;

: span-tag ( style quot -- )
    over css-style dup "" = [
        drop call
    ] [
        <span style= span> call </span>
    ] ifte ;

: resolve-file-link ( path -- link )
    #! The file responder needs relative links not absolute
    #! links.
    "doc-root" get [
        ?str-head [ "/" ?str-head drop ] when
    ] when* "/" ?str-tail drop ;

: file-link-href ( path -- href )
    <% "/file/" % resolve-file-link url-encode % %> ;

: file-link-tag ( style quot -- )
    over "file-link" swap assoc [
        <a href= file-link-href a> call </a>
    ] [
        call
    ] ifte* ;

: object-link-href ( path -- href )
    "/inspect/" swap cat2 ;

: object-link-tag ( style quot -- )
    over "object-link" swap assoc [
        <a href= object-link-href url-encode a> call </a>
    ] [
        call
    ] ifte* ;

: icon-tag ( string style quot -- )
    over "icon" swap assoc dup [
        <img src= "/resource/" swap cat2 img/>
        #! Ignore the quotation, since no further style
        #! can be applied
        3drop
    ] [
        drop call
    ] ifte ;

: html-write-attr ( string style -- )
    [
        [
            [
                [ drop chars>entities write ] span-tag
            ] file-link-tag
        ] object-link-tag
    ] icon-tag ;

: <html-stream> ( stream -- stream )
    #! Wraps the given stream in an HTML stream. An HTML stream
    #! converts special characters to entities when being
    #! written, and supports writing attributed strings with
    #! the following attributes:
    #!
    #! link - an object path
    #! fg - an rgb triplet in a list
    #! bg - an rgb triplet in a list
    #! bold
    #! italics
    #! underline
    #! size
    #! link - an object path
    <extend-stream> [
        [ chars>entities write ] "fwrite" set
        [ chars>entities print ] "fprint" set
        [ html-write-attr ] "fwrite-attr" set
    ] extend ;

: with-html-stream ( quot -- )
    [ "stdio" get <html-stream> "stdio" set call ] with-scope ;

: html-document ( title quot -- )
    swap chars>entities dup
    <html>
        <head>
            <title> write </title>
        </head>
        <body>
            <h1> write </h1>
            call
        </body>
    </html> ;

: simple-html-document ( title quot -- )
    swap [ <pre> with-html-stream </pre> ] html-document ;
