! :folding=indent:collapseFolds=0:

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

IN: wiki-responder
USE: combinators
USE: format
USE: html
USE: lists
USE: logic
USE: kernel
USE: namespaces
USE: regexp
USE: stdio
USE: stack
USE: strings

USE: httpd
USE: httpd-responder

: wiki-word-regexp ( -- regexp )
    "((?:[A-Z][a-z0-9]*){2,})" ;

: wiki-word? ( word -- ? )
    wiki-word-regexp re-matches ;

: wiki-word-links ( str -- str )
    wiki-word-regexp "$1" "$1" link-tag re-replace ;

: get-wiki-page ( name -- text )
    "wiki" get [ get ] bind ;

: write-wiki-page ( text -- )
    [ chars>entities wiki-word-links write ] preformatted-html ;

: wiki-nodes ( -- alist )
    "wiki" get [ vars-values ] bind ;

: search-wiki ( string -- alist )
    wiki-nodes [ dupd cdr str-contains? ] subset nip ;

: get-category-text ( category -- text )
    <% search-wiki [ car % "\n" % ] each %> ;

: serve-category-page ( name text -- )
    swap [ write-wiki-page ] html-document ;

: wiki-footer ( name -- )
    "<hr>" print
    "Edit" swap "edit?" swap cat2 link-tag write ;

: serve-existing-page ( name text -- )
    over [ write-wiki-page wiki-footer ] html-document ;

: wiki-editor ( name text -- )
    "<form action='" write
    swap write
    "' method='post'>" print
    "<textarea name='text' cols='64' rows='16'>" write
    [ chars>entities write ] when*
    "</textarea><p>" print
    "<input type='Submit' value='Submit'></form>" write ;

: serve-edit-page ( name text -- )
    over [
        over wiki-word? [
            wiki-editor
        ] [
            drop "Not a wiki word: " write write
        ] ifte
    ] html-document ;

: wiki-get-responder ( argument -- )
    serving-html

    dup "edit?" str-head? dup [
        nip dup get-wiki-page serve-edit-page
    ] [
        drop dup "Category" str-head? [
            dup get-category-text serve-category-page
        ] [
            dup get-wiki-page dup [
                serve-existing-page
            ] [
                serve-edit-page
            ] ifte
        ] ifte
    ] ifte ;

: set-wiki-page ( name text -- )
    "wiki" get [ put ] bind ;

: wiki-post-responder ( argument -- )
    #! Handle a page edit.
    "response" get dup [
        "text=" str-head? dup [
            2dup set-wiki-page serve-existing-page
        ] [
            2drop bad-request
        ] ifte
    ] [
        2drop bad-request
    ] ifte ;
