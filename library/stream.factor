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

IN: streams
USE: errors
USE: kernel
USE: namespaces

: fflush ( stream -- )
    [ "fflush" get call ] bind ;

: freadln ( stream -- string )
    [ "freadln" get call ] bind ;

: fread# ( count stream -- string )
    [ "fread#" get call ] bind ;

: fprint ( string stream -- )
    [ "fprint" get call ] bind ;

: fwrite ( string stream -- )
    [ "fwrite" get call ] bind ;

: fwrite-attr ( string stream -- )
    #! Write an attributed string to the given stream.
    #! The attributes are taken from the current namespace;
    #! supported keys depend on the type of stream.
    [ "fwrite-attr" get call ] bind ;

: fedit ( string stream -- )
    [ "fedit" get call ] bind ;

: fclose ( stream -- )
    [ "fclose" get call ] bind ;

: <stream> ( -- stream )
    #! Create a stream object.
    <namespace> [
        ( -- string )
        [ "freadln not implemented." throw ] "freadln" set
        ( count -- string )
        [ "fread# not implemented."  throw ] "fread#" set
        ( string -- )
        [ "fwrite not implemented."  throw ] "fwrite" set
        ( string attrs -- )
        [ namespace fwrite ] "fwrite-attr" set
        ( string -- )
        [ "fedit not implemented."   throw ] "fedit" set
        ( -- )
        [ ] "fflush" set
        ( -- )
        [ ] "fclose" set
        ( string -- )
        [ namespace fwrite "\n" namespace fwrite ] "fprint" set
    ] extend ;

: <extend-stream> ( stream -- stream )
    <stream> [
        "stream" set
        ( -- string )
        [ "stream" get freadln ] "freadln" set
        ( count -- string )
        [ "stream" get fread# ] "fread#" set
        ( string -- )
        [ "stream" get fwrite ] "fwrite" set
        ( string attrs -- )
        [ "stream" get fwrite-attr ] "fwrite-attr" set
        ( string -- )
        [ "stream" get fedit ] "fedit" set
        ( -- )
        [ "stream" get fflush ] "fflush" set
        ( -- )
        [ "stream" get fclose ] "fclose" set
        ( string -- )
        [ "stream" get fprint ] "fprint" set
    ] extend ;
