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

: opening-tag ( tag attrs -- )
    "<" % swap % [ " " % % ] when* ">" % ;

: closing-tag ( tag -- )
    "</" % % ">" % ;

: html-tag ( str tag attrs -- str )
    #! Wrap a string in an HTML tag.
    <% dupd opening-tag swap % closing-tag %> ;

: link-attrs ( link -- attrs )
    <% "href=\"/inspect/" % % "\"" % %> ;

: link-tag ( string link -- string )
    url-encode "a" swap link-attrs html-tag ;

: >hex-color ( triplet -- hex )
    [ >hex 2 digits ] inject "#" swons cat ;

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

: css-style% ( style -- )
    [
        [ "fg"        fg-css% ]
        [ "bold"      bold-css% ]
        [ "italics"   italics-css% ]
        [ "underline" underline-css% ]
        [ "size"      size-css% ]
        [ "font"      font-css% ]
    ] assoc-apply ;

: span-tag ( string style -- string )
    "span" swap <% "style=\"" % css-style% "\"" % %> html-tag ;

: html-attr-string ( string style -- string )
    [ span-tag ] keep "link" swap assoc [ link-tag ] when* ;

: html-write-attr ( string style -- )
    swap chars>entities swap html-attr-string write ;

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
    [
        "stdio" get <html-stream> "stdio" set call
    ] with-scope ;

: html-head ( title -- )
    "<html><head><title>" write
    dup write
    "</title></head><body><h1>" write write "</h1>" write ;

: html-tail ( -- ) "</body></html>" print ;

: html-document ( title quot -- )
    swap chars>entities html-head call html-tail ;

: preformatted-html ( quot -- )
    "<pre>" print call "</pre>" print ;

: simple-html-document ( title quot -- )
    swap [
        [ [ call ] with-html-stream ] preformatted-html
    ] html-document ;
