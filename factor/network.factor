!:folding=indent:collapseFolds=1:

! $Id$
!
! Copyright (C) 2003 Slava Pestov.
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

: <client> ( server port -- stream )
    #! Open a TCP/IP socket to a port on the given server.
    [ "java.lang.String" "int" ] "java.net.Socket" jnew
    <socketstream> ;

: <server> ( port -- stream )
    #! Starts listening on localhost:port. Returns a stream that
    #! you can close with fclose. No other stream operations are
    #! supported.
    [ "int" ] "java.net.ServerSocket" jnew
    <stream> [
        @socket

        ( -- )
        [
            $socket [ ] "java.net.ServerSocket" "close" jinvoke
        ] @fclose
    ] extend ;

: <socketstream> ( socket -- stream )
    #! Wraps a socket inside a byte-stream.
    dup
    [ [ ] "java.net.Socket" "getInputStream"  jinvoke ]
    [ [ ] "java.net.Socket" "getOutputStream" jinvoke ]
    cleave
    <byte-stream> [
        @socket

        ! We "extend" byte-stream's fclose.
        ( -- )
        $fclose [
            $socket [ ] "java.net.Socket" "close" jinvoke
        ] append @fclose
    ] extend ;

: accept ( server -- client )
    #! Accept a connection from a server socket.
    [ $socket ] bind
    [ ] "java.net.ServerSocket" "accept" jinvoke <socketstream> ;
