! Copyright (C) 2006 Mackenzie Straight, Doug Coleman.

USING: alien alien.c-types alien.syntax arrays byte-arrays kernel
math sequences windows.types windows.kernel32 windows.errors structs
windows ;
IN: windows.winsock

USE: libc
: alien>byte-array ( alien str -- byte-array )
    heap-size dup <byte-array> [ -rot memcpy ] keep ;

TYPEDEF: void* SOCKET

: <wsadata> ( -- byte-array )
    HEX: 190 <byte-array> ;

: SOCK_STREAM    1 ; inline
: SOCK_DGRAM     2 ; inline
: SOCK_RAW       3 ; inline
: SOCK_RDM       4 ; inline
: SOCK_SEQPACKET 5 ; inline

: SO_DEBUG       HEX:   1 ; inline
: SO_ACCEPTCONN  HEX:   2 ; inline
: SO_REUSEADDR   HEX:   4 ; inline
: SO_KEEPALIVE   HEX:   8 ; inline
: SO_DONTROUTE   HEX:  10 ; inline
: SO_BROADCAST   HEX:  20 ; inline
: SO_USELOOPBACK HEX:  40 ; inline
: SO_LINGER      HEX:  80 ; inline
: SO_OOBINLINE   HEX: 100 ; inline
: SO_DONTLINGER SO_LINGER bitnot ; inline

: SO_SNDBUF     HEX: 1001 ; inline
: SO_RCVBUF     HEX: 1002 ; inline
: SO_SNDLOWAT   HEX: 1003 ; inline
: SO_RCVLOWAT   HEX: 1004 ; inline
: SO_SNDTIMEO   HEX: 1005 ; inline
: SO_RCVTIMEO   HEX: 1006 ; inline
: SO_ERROR      HEX: 1007 ; inline
: SO_TYPE       HEX: 1008 ; inline

: TCP_NODELAY   HEX:    1 ; inline

: AF_UNSPEC      0 ; inline
: AF_UNIX        1 ; inline
: AF_INET        2 ; inline
: AF_IMPLINK     3 ; inline
: AF_PUP         4 ; inline
: AF_CHAOS       5 ; inline
: AF_NS          6 ; inline
: AF_ISO         7 ; inline
: AF_OSI    AF_ISO ; inline
: AF_ECMA        8 ; inline
: AF_DATAKIT     9 ; inline
: AF_CCITT      10 ; inline
: AF_SNA        11 ; inline
: AF_DECnet     12 ; inline
: AF_DLI        13 ; inline
: AF_LAT        14 ; inline
: AF_HYLINK     15 ; inline
: AF_APPLETALK  16 ; inline
: AF_NETBIOS    17 ; inline
: AF_MAX        18 ; inline
: AF_INET6      23 ; inline
: AF_IRDA       26 ; inline
: AF_BTM        32 ; inline

: PF_UNSPEC      0 ; inline
: PF_LOCAL       1 ; inline
: PF_INET        2 ; inline
: PF_INET6      23 ; inline

: AI_PASSIVE     1 ; inline
: AI_CANONNAME   2 ; inline
: AI_NUMERICHOST 4 ; inline
: AI_MASK AI_PASSIVE AI_CANONNAME bitor AI_NUMERICHOST bitor ;

: NI_NUMERICHOST 1 ;
: NI_NUMERICSERV 2 ;

: IPPROTO_TCP    6 ; inline
: IPPROTO_UDP   17 ; inline
: IPPROTO_RM   113 ; inline

: WSA_FLAG_OVERLAPPED 1 ; inline
: WSA_WAIT_EVENT_0 WAIT_OBJECT_0 ; inline
: WSA_MAXIMUM_WAIT_EVENTS MAXIMUM_WAIT_OBJECTS ; inline
: WSA_INVALID_EVENT f ; inline
: WSA_WAIT_FAILED -1 ; inline
: WSA_WAIT_IO_COMPLETION WAIT_IO_COMPLETION ; inline
: WSA_WAIT_TIMEOUT WAIT_TIMEOUT ; inline
: WSA_INFINITE INFINITE ; inline
: WSA_IO_PENDING ERROR_IO_PENDING ; inline

: INADDR_ANY 0 ; inline

: INVALID_SOCKET -1 <alien> ; inline
: SOCKET_ERROR -1 ; inline

: SD_RECV 0 ; inline
: SD_SEND 1 ; inline
: SD_BOTH 2 ; inline

: SOL_SOCKET HEX: ffff ; inline

! TYPEDEF: uint in_addr_t
! C-STRUCT: in_addr
    ! { "in_addr_t" "s_addr" } ;

C-STRUCT: sockaddr-in
    { "short" "family" }
    { "ushort" "port" }
    { "uint" "addr" }
    { { "char" 8 } "pad" } ;

C-STRUCT: sockaddr-in6
    { "uchar" "family" }
    { "ushort" "port" }
    { "uint" "flowinfo" }
    { { "uchar" 16 } "addr" }
    { "uint" "scopeid" } ;

C-STRUCT: hostent
    { "char*" "name" }
    { "void*" "aliases" }
    { "short" "addrtype" }
    { "short" "length" }
    { "void*" "addr-list" } ;

C-STRUCT: addrinfo
    { "int" "flags" }
    { "int" "family" }
    { "int" "socktype" }
    { "int" "protocol" }
    { "size_t" "addrlen" }
    { "char*" "canonname" }
    { "sockaddr*" "addr" }
    { "addrinfo*" "next" } ;

: hostent-addr hostent-addr-list *void* ; ! *uint ;

LIBRARY: winsock


FUNCTION: int setsockopt ( SOCKET s, int level, int optname, char* optval, int optlen ) ;

FUNCTION: ushort htons ( ushort n ) ;
FUNCTION: ushort ntohs ( ushort n ) ;
<PRIVATE
FUNCTION: int bind ( void* socket, sockaddr_in* sockaddr, int len ) ;
FUNCTION: int listen ( void* socket, int backlog ) ;
FUNCTION: char* inet_ntoa ( int in-addr ) ;
PRIVATE>
FUNCTION: int getaddrinfo ( char* nodename,
                            char* servername,
                            addrinfo* hints,
                            addrinfo** res ) ;

FUNCTION: void freeaddrinfo ( addrinfo* ai ) ;


FUNCTION: hostent* gethostbyname ( char* name ) ;
FUNCTION: int gethostname ( char* name, int len ) ;
FUNCTION: int connect ( void* socket, sockaddr_in* sockaddr, int addrlen ) ;
FUNCTION: int select ( int nfds, fd_set* readfds, fd_set* writefds, fd_set* exceptfds, timeval* timeout ) ;
FUNCTION: int closesocket ( SOCKET s ) ;
FUNCTION: int shutdown ( SOCKET s, int how ) ;
FUNCTION: int send ( SOCKET s, char* buf, int len, int flags ) ;
FUNCTION: int recv ( SOCKET s, char* buf, int len, int flags ) ;

TYPEDEF: uint SERVICETYPE
TYPEDEF: OVERLAPPED WSAOVERLAPPED
TYPEDEF: WSAOVERLAPPED* LPWSAOVERLAPPED
TYPEDEF: uint GROUP
TYPEDEF: void* LPCONDITIONPROC
TYPEDEF: HANDLE WSAEVENT
TYPEDEF: LPHANDLE LPWSAEVENT
TYPEDEF: sockaddr* LPSOCKADDR

C-STRUCT: FLOWSPEC
    { "uint"        "TokenRate" }
    { "uint"        "TokenBucketSize" }
    { "uint"        "PeakBandwidth" }
    { "uint"        "Latency" }
    { "uint"        "DelayVariation" }
    { "SERVICETYPE" "ServiceType" }
    { "uint"        "MaxSduSize" }
    { "uint"        "MinimumPolicedSize" } ;
TYPEDEF: FLOWSPEC* PFLOWSPEC
TYPEDEF: FLOWSPEC* LPFLOWSPEC

C-STRUCT: WSABUF
    { "ulong" "len" }
    { "void*" "buf" } ;
TYPEDEF: WSABUF* LPWSABUF

C-STRUCT: QOS
    { "FLOWSPEC" "SendingFlowspec" }
    { "FLOWSPEC" "ReceivingFlowspec" }
    { "WSABUF" "ProviderSpecific" } ;
TYPEDEF: QOS* LPQOS

: MAX_PROTOCOL_CHAIN 7 ; inline

C-STRUCT: WSAPROTOCOLCHAIN
    { "int" "ChainLen" }
    ! { { "DWORD" MAX_PROTOCOL_CHAIN } "ChainEntries" } ;
    { { "DWORD" 7 } "ChainEntries" } ;
TYPEDEF: WSAPROTOCOLCHAIN* LPWSAPROTOCOLCHAIN

: WSAPROTOCOL_LEN 255 ; inline

C-STRUCT: WSAPROTOCOL_INFOW
    { "DWORD" "dwServiceFlags1" }
    { "DWORD" "dwServiceFlags2" }
    { "DWORD" "dwServiceFlags3" }
    { "DWORD" "dwServiceFlags4" }
    { "DWORD" "dwProviderFlags" }
    { "GUID" "ProviderId" }
    { "DWORD" "dwCatalogEntryId" }
    { "WSAPROTOCOLCHAIN" "ProtocolChain" }
    { "int" "iVersion" }
    { "int" "iAddressFamily" }
    { "int" "iMaxSockAddr" }
    { "int" "iMinSockAddr" }
    { "int" "iSocketType" }
    { "int" "iProtocol" }
    { "int" "iProtocolMaxOffset" }
    { "int" "iNetworkByteOrder" }
    { "int" "iSecurityScheme" }
    { "DWORD" "dwMessageSize" }
    { "DWORD" "dwProviderReserved" }
    { { "WCHAR" 256 } "szProtocol" } ;
    ! { { "WCHAR" 256 } "szProtocol"[WSAPROTOCOL_LEN+1] } ;
TYPEDEF: WSAPROTOCOL_INFOW* PWSAPROTOCOL_INFOW
TYPEDEF: WSAPROTOCOL_INFOW* LPWSAPROTOCOL_INFOW
TYPEDEF: WSAPROTOCOL_INFOW WSAPROTOCOL_INFO
TYPEDEF: WSAPROTOCOL_INFOW* PWSAPROTOCOL_INFO
TYPEDEF: WSAPROTOCOL_INFOW* LPWSAPROTOCOL_INFO


C-STRUCT: WSANAMESPACE_INFOW
    { "GUID"    "NSProviderId" }
    { "DWORD"   "dwNameSpace" }
    { "BOOL"    "fActive" }
    { "DWORD"   "dwVersion" }
    { "LPWSTR"  "lpszIdentifier" } ;
TYPEDEF: WSANAMESPACE_INFOW* PWSANAMESPACE_INFOW
TYPEDEF: WSANAMESPACE_INFOW* LPWSANAMESPACE_INFOW
TYPEDEF: WSANAMESPACE_INFOW WSANAMESPACE_INFO
TYPEDEF: WSANAMESPACE_INFO* PWSANAMESPACE_INFO
TYPEDEF: WSANAMESPACE_INFO* LPWSANAMESPACE_INFO

: FD_MAX_EVENTS 10 ;

C-STRUCT: WSANETWORKEVENTS
    { "long" "lNetworkEvents" }
    ! { { "int" "FD_MAX_EVENTS" } "iErrorCode" } ;
    { { "int" 10 } "iErrorCode" } ;
TYPEDEF: WSANETWORKEVENTS* PWSANETWORKEVENTS
TYPEDEF: WSANETWORKEVENTS* LPWSANETWORKEVENTS

! C-STRUCT: WSAOVERLAPPED
    ! { "DWORD" "Internal" }
    ! { "DWORD" "InternalHigh" }
    ! { "DWORD" "Offset" }
    ! { "DWORD" "OffsetHigh" }
    ! { "WSAEVENT" "hEvent" }
    ! { "DWORD" "bytesTransferred" } ;
! TYPEDEF: WSAOVERLAPPED* LPWSAOVERLAPPED

FUNCTION: SOCKET WSAAccept ( SOCKET s,
                             sockaddr* addr,
                             LPINT addrlen,
                             LPCONDITIONPROC lpfnCondition,
                             DWORD dwCallbackData ) ;

! FUNCTION: INT WSAAddressToString ( LPSOCKADDR lpsaAddress, DWORD dwAddressLength, LPWSAPROTOCOL_INFO lpProtocolInfo, LPTSTR lpszAddressString, LPDWORD lpdwAddressStringLength ) ;

FUNCTION: int WSACleanup ( ) ;
FUNCTION: BOOL WSACloseEvent ( WSAEVENT hEvent ) ;

FUNCTION: int WSAConnect ( SOCKET s,
                           sockaddr* name,
                           int namelen,
                           LPWSABUF lpCallerData,
                           LPWSABUF lpCalleeData,
                           LPQOS lpSQOS,
                           LPQOS lpGQOS ) ;
FUNCTION: WSAEVENT WSACreateEvent ( ) ;
! FUNCTION: INT WSAEnumNameSpaceProviders ( LPDWORD lpdwBufferLength, LPWSANAMESPACE_INFO lpnspBuffer ) ;
FUNCTION: int WSAEnumNetworkEvents ( SOCKET s,
                                     WSAEVENT hEventObject,
                                     LPWSANETWORKEVENTS lpNetworkEvents ) ;
! FUNCTION: int WSAEnumProtocols ( LPINT lpiProtocols, LPWSAPROTOCOL_INFO lpProtocolBuffer, LPDWORD lpwdBufferLength ) ;

FUNCTION: int WSAEventSelect ( SOCKET s,
                               WSAEVENT hEventObject,
                               long lNetworkEvents ) ;
FUNCTION: int WSAGetLastError ( ) ;
FUNCTION: BOOL WSAGetOverlappedResult ( SOCKET s,
                                        LPWSAOVERLAPPED lpOverlapped,
                                        LPDWORD lpcbTransfer,
                                        BOOL fWait,
                                        LPDWORD lpdwFlags ) ;

FUNCTION: int WSAIoctl ( SOCKET s,
                         DWORD dwIoControlCode,
                         LPVOID lpvInBuffer,
                         DWORD cbInBuffer,
                         LPVOID lpvOutBuffer,
                         DWORD cbOutBuffer,
                         LPDWORD lpcbBytesReturned,
                         void* lpOverlapped,
                         void* lpCompletionRoutine ) ;

TYPEDEF: void* LPWSAOVERLAPPED_COMPLETION_ROUTINE
FUNCTION: int WSARecv ( SOCKET s,
                        LPWSABUF lpBuffers,
                        DWORD dwBufferCount,
                        LPDWORD lpNumberOfBytesRecvd,
                        LPDWORD lpFlags,
                        LPWSAOVERLAPPED lpOverlapped,
                    LPWSAOVERLAPPED_COMPLETION_ROUTINE lpCompletionRoutine ) ;

FUNCTION: int WSARecvFrom ( SOCKET s,
                    LPWSABUF lpBuffers,
                    DWORD dwBufferCount,
                    LPDWORD lpNumberOfBytesRecvd,
                    LPDWORD lpFlags,
                    sockaddr* lpFrom,
                    LPINT lpFromlen,
                    LPWSAOVERLAPPED lpOverlapped,
                    LPWSAOVERLAPPED_COMPLETION_ROUTINE lpCompletionRoutine ) ;

FUNCTION: BOOL WSAResetEvent ( WSAEVENT hEvent ) ;
FUNCTION: int WSASend ( SOCKET s,
                        LPWSABUF lpBuffers,
                        DWORD dwBufferCount,
                        LPDWORD lpNumberOfBytesSent,
                        LPDWORD lpFlags,
                        LPWSAOVERLAPPED lpOverlapped,
                 LPWSAOVERLAPPED_COMPLETION_ROUTINE lpCompletionRoutine ) ;

FUNCTION: int WSASendTo ( SOCKET s,
                          LPWSABUF lpBuffers,
                          DWORD dwBufferCount,
                          LPDWORD lpNumberOfBytesSent,
                          DWORD dwFlags,
                          sockaddr* lpTo,
                          int iToLen,
                          LPWSAOVERLAPPED lpOverlapped,
  LPWSAOVERLAPPED_COMPLETION_ROUTINE lpCompletionRoutine ) ;


FUNCTION: int WSAStartup ( short version, void* out-data ) ;



FUNCTION: SOCKET WSASocketW ( int af,
                             int type,
                             int protocol,
                             LPWSAPROTOCOL_INFOW lpProtocolInfo,
                             GROUP g,
                             DWORD flags ) ;
: WSASocket WSASocketW ;

FUNCTION: DWORD WSAWaitForMultipleEvents ( DWORD cEvents,
                                           WSAEVENT* lphEvents,
                                           BOOL fWaitAll,
                                           DWORD dwTimeout,
                                           BOOL fAlertable ) ;




LIBRARY: mswsock

! Not in Windows CE
FUNCTION: int AcceptEx ( void* listen, void* accept, void* out-buf, int recv-len, int addr-len, int remote-len, void* out-len, void* overlapped ) ;
FUNCTION: void GetAcceptExSockaddrs ( void* a, int b, int c, int d, void* e, void* f, void* g, void* h ) ;

: SIO_GET_EXTENSION_FUNCTION_POINTER -939524090 ; inline

: WSAID_CONNECTEX
    "GUID" <c-object>
    HEX: 25a207b9 over set-GUID-Data1
    HEX: ddf3 over set-GUID-Data2
    HEX: 4660 over set-GUID-Data3
    B{
        HEX: 8e HEX: e9 HEX: 76 HEX: e5
        HEX: 8c HEX: 74 HEX: 06 HEX: 3e
    } over set-GUID-Data4 ;

: winsock-expected-error? ( n -- ? )
    ERROR_IO_PENDING ERROR_SUCCESS WSA_IO_PENDING 3array member? ;

: (winsock-error-string) ( n -- str )
    ! #! WSAStartup returns the error code 'n' directly
    dup winsock-expected-error?
    [ drop f ] [ error_message alien>u16-string ] if ;

: winsock-error-string ( -- string/f )
    WSAGetLastError (winsock-error-string) ;

: winsock-error ( -- )
    winsock-error-string [ throw ] when* ;

: winsock-error=0/f ( n/f -- )
    { 0 f } member? [
        winsock-error-string throw
    ] when ;

: winsock-error!=0/f ( n/f -- )
    dup { 0 f } member? [
        drop
    ] [
        (winsock-error-string) throw
    ] if ;

: socket-error* ( n -- )
    SOCKET_ERROR = [
        WSAGetLastError
        dup WSA_IO_PENDING = [
            drop
        ] [
            (winsock-error-string) throw
        ] if
    ] when ;

: socket-error ( n -- )
    SOCKET_ERROR = [ winsock-error ] when ;

: init-winsock ( -- )
    HEX: 0202 <wsadata> WSAStartup winsock-error!=0/f ;

