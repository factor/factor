!:folding=indent:collapseFolds=1:

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

: fwrite-attr ( string attrs stream -- )
    #! Write an attributed string to the given stream.
    #! The attributes are an alist; supported keys depend
    #! on the type of stream.
    [ $fwrite-attr [ drop $fwrite ] unless* call ] bind ;

: write-attr ( attrs stream -- )
    #! Write an attributed string to standard output.
    $stdio fwrite-attr ;

: <html-stream> ( stream -- stream )
    #! Wraps the given stream in an HTML stream. An HTML stream
    #! converts special characters to entities when being
    #! written, and supports writing attributed strings with
    #! the 'link' attribute.
    <extend-stream> [
        [ chars>entities $stream fwrite ] @fwrite
        [ chars>entities $stream fwriteln ] @fwriteln
        [ $stream <html-stream>/fwrite-attr ] @fwrite-attr
    ] extend ;

: object-path>link ( objpath -- string )
    chars>entities "inspect.lhtml?" swap cat2 ;

: html-link-string ( string link -- string )
    "<a href=\"" swap object-path>link "\">" cat3
    swap chars>entities
    "</a>" cat3 ;

: html-attr-string ( string attrs -- string )
    "link" swap assoc dup string? [
        html-link-string
    ] [
        drop
    ] ifte ;

: <html-stream>/fwrite-attr ( string attrs stream -- )
    [ html-attr-string ] dip fwrite ;

: unparse ( X -- "X" )
    [ "java.lang.Object" ] "factor.FactorReader" "unparseObject"
    jinvoke-static ;

: word-link ( word -- link )
    "dict'" swap "'def" cat3 ;

: defined-word? ( obj -- ? )
    dup word? [ worddef ] [ drop f ] ifte ;

: unparse. ( X -- "X" )
    dup defined-word? [
        "link" over word-link >str cons unit write-attr
    ] [
        unparse write
    ] ifte ;

: . ( expr -- )
    unparse. terpri ;
