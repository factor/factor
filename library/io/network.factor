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
USE: io-internals
USE: errors
USE: hashtables
USE: kernel
USE: stdio
USE: strings
USE: namespaces
USE: unparser
USE: generic

TRAITS: server

M: server fclose ( stream -- )
    [ "socket" get close-port ] bind ;M

C: server ( port -- stream )
    #! Starts listening on localhost:port. Returns a stream that
    #! you can close with fclose, and accept connections from
    #! with accept. No other stream operations are supported.
    [ server-socket "socket" set ] extend ;C

: <client-stream> ( host port in out -- stream )
    <fd-stream> [ ":" swap unparse cat3 "client" set ] extend ;

: <client> ( host port -- stream )
    #! fflush yields until connection is established.
    2dup client-socket <client-stream> dup fflush ;

: accept ( server -- client )
    #! Accept a connection from a server socket.
    "socket" swap hash blocking-accept <client-stream> ;
