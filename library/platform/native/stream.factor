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
        
        ( -- )
        [ "out" get [ flush-fd ] when* ] "fflush" set
        
        ( -- )
        [
            "in" get [ close-fd ] when*
            "out" get [ dup flush-fd close-fd ] when*
        ] "fclose" set
    ] extend ;

: <filecr> ( path -- stream )
    t f open-file f <fd-stream> ;

: <filecw> ( path -- stream )
    f t open-file f swap <fd-stream> ;

: <filebr> ( path -- stream )
    <filecr> ;

: <filebw> ( path -- stream )
    <filecw> ;

: <server> ( port -- stream )
    #! Starts listening on localhost:port. Returns a stream that
    #! you can close with fclose, and accept connections from
    #! with accept. No other stream operations are supported.
    server-socket <stream> [
        "socket" set

        ( -- )
        [ "socket" get close-fd ] "fclose" set
    ] extend ;

: <client-stream> ( host port socket -- stream )
    dup <fd-stream> [ "port" set "client" set ] extend ;

: accept ( server -- client )
    #! Accept a connection from a server socket.
    "socket" swap get* blocking-accept <client-stream> ;

: init-stdio ( -- )
    stdin stdout <fd-stream> <stdio-stream> "stdio" set ;

: exists? ( file -- ? )
    #! This is terrible.
    [ <filebr> fclose t ] [ nip not ] catch ;
