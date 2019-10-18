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

IN: win32-api
USE: alien
USE: kernel
USE: kernel-internals

: <wsadata> HEX: 190 <byte-array> ;

: AF_INET 2 ;
: SOCK_STREAM 1 ;
: WSA_FLAG_OVERLAPPED 1 ;
: INADDR_ANY 0 ;

BEGIN-STRUCT: sockaddr-in
    FIELD: short family
    FIELD: short port
    FIELD: int addr
    FIELD: char pad
    FIELD: char pad
    FIELD: char pad
    FIELD: char pad
    FIELD: char pad
    FIELD: char pad
    FIELD: char pad
    FIELD: char pad
END-STRUCT

: WSAStartup ( version out-data -- int )
    "int" "winsock" "WSAStartup" [ "short" "void*" ] alien-invoke ;

: WSASocket ( af type protocol protocol-info g flags -- socket )
    "void*" "winsock" "WSASocketA" [ "int" "int" "int" "void*" "void*" "int" ]
    alien-invoke ;

: htons ( short -- short ) 
    "ushort" "winsock" "htons" [ "ushort" ] alien-invoke ;

: ntohs ( short -- short )
    "ushort" "winsock" "ntohs" [ "ushort" ] alien-invoke ;

: wsa-bind ( socket sockaddr len -- status )
    "int" "winsock" "bind" [ "void*" "sockaddr-in*" "int" ] alien-invoke ;

: wsa-listen ( socket backlog -- status )
    "int" "winsock" "listen" [ "void*" "int" ] alien-invoke ;

: WSAGetLastError ( -- error )
    "int" "winsock" "WSAGetLastError" [ ] alien-invoke ;

: inet-ntoa ( in-addr -- str )
    "char*" "winsock" "inet_ntoa" [ "int" ] alien-invoke ; 

: AcceptEx 
( listen accept out-buf recv-len addr-len remote-len out-len overlapped -- ? )
    "bool" "mswsock" "AcceptEx"
    [ "void*" "void*" "void*" "int" "int" "int" "void*" "void*" ]
    alien-invoke ;

: GetAcceptExSockaddrs ( stack effect is too long to put here -- )
    "void" "mswsock" "GetAcceptExSockaddrs"
    [ "void*" "int" "int" "int" "void*" "void*" "void*" "void*" ] alien-invoke ;

BEGIN-STRUCT: hostent
    FIELD: char* name
    FIELD: void* aliases
    FIELD: short addrtype
    FIELD: short length
    FIELD: void* addr-list
END-STRUCT

: hostent-addr hostent-addr-list *void* *uint ;

: gethostbyname ( name -- hostent )
    "hostent*" "winsock" "gethostbyname" [ "char*" ] alien-invoke ;

: connect ( socket sockaddr addrlen -- int )
    "int" "winsock" "connect" [ "void*" "sockaddr-in*" "int" ] 
    alien-invoke ;

