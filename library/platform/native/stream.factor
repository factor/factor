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

IN: streams
USE: combinators
USE: continuations
USE: io-internals
USE: errors
USE: kernel
USE: logic
USE: stack
USE: stdio
USE: strings
USE: namespaces

: <fd-stream> ( in out -- stream )
    #! Create a file descriptor stream object, wrapping a pair
    #! of file descriptor handles for input and output.
    <stream> [
        "out" set
        "in" set

        ( str -- )
        [ "out" get blocking-write ] "fwrite" set
        
        ( -- str )
        [ "in" get dup [ blocking-read-line ] when ] "freadln" set
        
        ( count -- str )
        [
            "in" get dup [ blocking-read# ] [ nip ] ifte
        ] "fread#" set
        
        ( -- )
        [ "out" get [ blocking-flush ] when* ] "fflush" set
        
        ( -- )
        [
            "out" get [ dup blocking-flush close-port ] when*
            "in" get [ close-port ] when*
        ] "fclose" set
    ] extend ;

: <filecr> ( path -- stream )
    t f open-file <fd-stream> ;

: <filecw> ( path -- stream )
    f t open-file <fd-stream> ;

: <filebr> ( path -- stream )
    <filecr> ;

: <filebw> ( path -- stream )
    <filecw> ;

: init-stdio ( -- )
    stdin stdout <fd-stream> <stdio-stream> "stdio" set ;

: (fcopy) ( from to -- )
    #! Copy the contents of the fd-stream 'from' to the
    #! fd-stream 'to'. Use fcopy; this word does not close
    #! streams.
    "out" swap get* >r "in" swap get* r> blocking-copy ;

: fcopy ( from to -- )
    #! Copy the contents of the fd-stream 'from' to the
    #! fd-stream 'to'.
    [ 2dup (fcopy) ] [ -rot fclose fclose rethrow ] catch ;

: resource-path ( -- path )
    "resource-path" get [ "." ] unless* ;

: <resource-stream> ( path -- stream )
    resource-path swap cat2 <filecr> ;
