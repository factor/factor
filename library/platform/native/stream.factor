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
USE: io-internals
USE: kernel
USE: stack
USE: namespaces

: <c-stream> ( in out -- stream )
    #! Create a C stream object, wrapping a pair of FILE*
    #! handles for input and output.
    <stream> [
        "out" set
        "in" set

        ( string -- )
        [ "out" get write-8 ] "fwrite" set
        ( -- string )
        [ "in" get read-line-8 ] "freadln" set
        ( -- )
        [
            "in" get [ close ] when*
            "out" get [ close ] when*
        ] "fclose" set
    ] extend ;

: <file-stream> ( path mode -- stream )
    open-file dup <c-stream> ;

: <filebr> ( path -- stream )
    "r" <file-stream> ;

: <filebw> ( path -- stream )
    "w" <file-stream> ;

: <fd-stream> ( in out -- stream )
    #! Create a file descriptor stream object, wrapping a pair
    #! of file descriptor handles for input and output.
    <stream> [
        "out" set
        "in" set

        ( -- )
        [
            "in" get [ close-fd ] when*
            "out" get [ close-fd ] when*
        ] "fclose" set
    ] extend ;

: <server> ( port -- stream )
    #! Starts listening on localhost:port. Returns a stream that
    #! you can close with fclose, and accept connections from
    #! with accept. No other stream operations are supported.
    server-socket <stream> [
        "socket" set

        ( -- )
        [ "socket" get close-fd ] "fclose" set
    ] extend ;

: accept ( server -- client )
    #! Accept a connection from a server socket.
    [ "socket" get ] bind accept-fd dup <fd-stream> ;

: init-stdio ( -- )
    stdin stdout <c-stream> "stdio" set ;
