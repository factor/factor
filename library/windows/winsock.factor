! Copyright (C) 2006 Mackenzie Straight, Doug Coleman.

IN: win32-api
USING: alien arrays kernel ;

: <wsadata> ( -- byte-array )
    HEX: 190 <byte-array> ;

: AF_INET 2 ; inline
: SOCK_STREAM 1 ; inline
: WSA_FLAG_OVERLAPPED 1 ; inline
: INADDR_ANY 0 ; inline
: INVALID_SOCKET -1 ; inline

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

BEGIN-STRUCT: hostent
    FIELD: char* name
    FIELD: void* aliases
    FIELD: short addrtype
    FIELD: short length
    FIELD: void* addr-list
END-STRUCT

: hostent-addr hostent-addr-list *void* *uint ;

LIBRARY: winsock

FUNCTION: int WSAStartup ( short version, void* out-data ) ;
FUNCTION: void* WSASocketA ( int af,
                             int type,
                             int protocol,
                             void* protocol-info,
                             void* g,
                             int flags ) ;
: WSASocket WSASocketA ;

FUNCTION: ushort htons ( ushort n ) ;
FUNCTION: ushort ntohs ( ushort n ) ;
IN: win32-api-internals
FUNCTION: int bind ( void* socket, sockaddr-in* sockaddr, int len ) ;
FUNCTION: int listen ( void* socket, int backlog ) ;
FUNCTION: char* inet_ntoa ( int in-addr ) ;
IN: win32-api
: wsa-bind bind ;
: wsa-listen listen ;
: inet-ntoa inet_ntoa ;
FUNCTION: int WSAGetLastError ( ) ;
FUNCTION: hostent* gethostbyname ( char* name ) ;
FUNCTION: int connect ( void* socket, sockaddr-in* sockaddr, int addrlen ) ;

LIBRARY: mswsock

FUNCTION: bool AcceptEx ( void* listen, void* accept, void* out-buf, int recv-len, int addr-len, int remote-len, void* out-len, void* overlapped ) ;
FUNCTION: void GetAcceptExSockaddrs ( void* a, int b, int c, int d, void* e, void* f, void* g, void* h ) ;
