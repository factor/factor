! Copyright (C) 2004 Mackenzie Straight.

IN: win32-api
USE: alien
USE: kernel
USE: kernel-internals
USE: sequences-internals
USE: arrays

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

