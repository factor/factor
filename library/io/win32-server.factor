! :folding=indent:collapseFolds=1:

! $Id$
!
! Copyright (C) 2004 Mackenzie Straight.
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

IN: win32-stream
USE: alien
USE: errors
USE: generic
USE: kernel
USE: kernel-internals
USE: lists
USE: math
USE: namespaces
USE: prettyprint
USE: stdio
USE: streams
USE: strings
USE: threads
USE: unparser
USE: win32-api
USE: win32-io-internals

TUPLE: win32-server this ;
TUPLE: win32-client-stream delegate host ;
SYMBOL: winsock
SYMBOL: socket

: maybe-init-winsock ( -- )
    winsock get [
        HEX: 0202 <wsadata> WSAStartup drop winsock on
    ] unless ;

: handle-socket-error ( -- )
    WSAGetLastError [
      ERROR_IO_PENDING ERROR_SUCCESS
    ] contains? [
      win32-error-message throw 
    ] unless ;

: new-socket ( -- socket )
    AF_INET SOCK_STREAM 0 NULL NULL WSA_FLAG_OVERLAPPED WSASocket ;

: setup-sockaddr ( port -- sockaddr )
    <sockaddr-in> swap
    htons over set-sockaddr-in-port
    INADDR_ANY over set-sockaddr-in-addr 
    AF_INET over set-sockaddr-in-family ;

: bind-socket ( port socket -- )
    swap setup-sockaddr "sockaddr-in" size wsa-bind 0 = [
        handle-socket-error
    ] unless ;

: listen-socket ( socket -- )
    20 wsa-listen 0 = [ handle-socket-error ] unless ;

C: win32-client-stream ( buf stream -- stream )
    [ set-win32-client-stream-delegate ] keep >r
    buffer-ptr <alien> 0 32 32 
    <sockaddr-in> dup >r <indirect-pointer> <sockaddr-in> dup >r 
    <indirect-pointer> GetAcceptExSockaddrs r> r> drop
    dup sockaddr-in-port ntohs swap sockaddr-in-addr inet-ntoa
    [ , ":" , unparse , ] make-string
    r> [ set-win32-client-stream-host ] keep ;

M: win32-client-stream client-stream-host win32-client-stream-host ;

C: win32-server ( port -- server )
    swap <namespace> [ 
        maybe-init-winsock new-socket swap over bind-socket dup listen-socket 
        dup add-completion
        socket set
    ] extend over set-win32-server-this ;

M: win32-server fclose ( server -- )
    win32-server-this [ socket get CloseHandle drop ] bind ;

M: win32-server accept ( server -- client )
    win32-server-this [
        new-socket 64 <buffer>
        [
            alloc-io-task init-overlapped >r >r >r socket get r> r> 
            buffer-ptr <alien> 0 32 32 NULL r> AcceptEx
            [ handle-socket-error ] unless (yield)
        ] callcc0
        swap dup add-completion <win32-stream> dupd <win32-client-stream>
        swap buffer-free
    ] bind ;

