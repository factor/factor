! Copyright (C) 2006 Mackenzie Straight, Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types alien.data alien.syntax
byte-arrays classes.struct grouping init kernel literals math
math.parser sequences system vocabs.parser windows.com.syntax
windows.errors windows.kernel32 windows.types ;
IN: windows.winsock

<<
! Some differences between Win32 and Win64
cpu x86.64? "windows.winsock.64" "windows.winsock.32" ? use-vocab
>>

TYPEDEF: int* SOCKET

: <wsadata> ( -- byte-array )
    0x190 <byte-array> ;

CONSTANT: SOCK_STREAM    1
CONSTANT: SOCK_DGRAM     2
CONSTANT: SOCK_RAW       3
CONSTANT: SOCK_RDM       4
CONSTANT: SOCK_SEQPACKET 5

CONSTANT: SO_DEBUG       0x1
CONSTANT: SO_ACCEPTCONN  0x2
CONSTANT: SO_REUSEADDR   0x4
CONSTANT: SO_KEEPALIVE   0x8
CONSTANT: SO_DONTROUTE   0x10
CONSTANT: SO_BROADCAST   0x20
CONSTANT: SO_USELOOPBACK 0x40
CONSTANT: SO_LINGER      0x80
CONSTANT: SO_OOBINLINE   0x100
: SO_DONTLINGER ( -- n ) SO_LINGER bitnot ; inline

CONSTANT: SO_SNDBUF     0x1001
CONSTANT: SO_RCVBUF     0x1002
CONSTANT: SO_SNDLOWAT   0x1003
CONSTANT: SO_RCVLOWAT   0x1004
CONSTANT: SO_SNDTIMEO   0x1005
CONSTANT: SO_RCVTIMEO   0x1006
CONSTANT: SO_ERROR      0x1007
CONSTANT: SO_TYPE       0x1008

CONSTANT: TCP_NODELAY   0x1

CONSTANT: AF_UNSPEC      0
CONSTANT: AF_UNIX        1
CONSTANT: AF_INET        2
CONSTANT: AF_IMPLINK     3
CONSTANT: AF_PUP         4
CONSTANT: AF_CHAOS       5
CONSTANT: AF_NS          6
CONSTANT: AF_ISO         7
ALIAS: AF_OSI    AF_ISO
CONSTANT: AF_ECMA        8
CONSTANT: AF_DATAKIT     9
CONSTANT: AF_CCITT      10
CONSTANT: AF_SNA        11
CONSTANT: AF_DECnet     12
CONSTANT: AF_DLI        13
CONSTANT: AF_LAT        14
CONSTANT: AF_HYLINK     15
CONSTANT: AF_APPLETALK  16
CONSTANT: AF_NETBIOS    17
CONSTANT: AF_MAX        18
CONSTANT: AF_INET6      23
CONSTANT: AF_IRDA       26
CONSTANT: AF_BTM        32

CONSTANT: PF_UNSPEC      0
CONSTANT: PF_LOCAL       1
CONSTANT: PF_INET        2
CONSTANT: PF_INET6      23

CONSTANT: AI_PASSIVE        0x0001
CONSTANT: AI_CANONNAME      0x0002
CONSTANT: AI_NUMERICHOST    0x0004
CONSTANT: AI_ALL            0x0100
CONSTANT: AI_ADDRCONFIG     0x0400

CONSTANT: AI_MASK flags{ AI_PASSIVE AI_CANONNAME AI_NUMERICHOST }

CONSTANT: NI_NUMERICHOST 1
CONSTANT: NI_NUMERICSERV 2

CONSTANT: IPPROTO_IP        0           ! Dummy protocol for TCP.
CONSTANT: IPPROTO_ICMP      1           ! Internet Control Message Protocol.
CONSTANT: IPPROTO_IGMP      2           ! Internet Group Management Protocol. */
CONSTANT: IPPROTO_IPIP      4           ! IPIP tunnels (older KA9Q tunnels use 94).
CONSTANT: IPPROTO_TCP       6           ! Transmission Control Protocol.
CONSTANT: IPPROTO_EGP       8           ! Exterior Gateway Protocol.
CONSTANT: IPPROTO_PUP      12           ! PUP protocol.
CONSTANT: IPPROTO_UDP      17           ! User Datagram Protocol.
CONSTANT: IPPROTO_IDP      22           ! XNS IDP protocol.
CONSTANT: IPPROTO_TP       29           ! SO Transport Protocol Class 4.
CONSTANT: IPPROTO_DCCP     33           ! Datagram Congestion Control Protocol.
CONSTANT: IPPROTO_IPV6     41           ! IPv6 header.
CONSTANT: IPPROTO_RSVP     46           ! Reservation Protocol.
CONSTANT: IPPROTO_GRE      47           ! General Routing Encapsulation.
CONSTANT: IPPROTO_ESP      50           ! encapsulating security payload.
CONSTANT: IPPROTO_AH       51           ! authentication header.
CONSTANT: IPPROTO_MTP      92           ! Multicast Transport Protocol.
CONSTANT: IPPROTO_BEETPH   94           ! IP option pseudo header for BEET.
CONSTANT: IPPROTO_ENCAP    98           ! Encapsulation Header.
CONSTANT: IPPROTO_PIM     103           ! Protocol Independent Multicast.
CONSTANT: IPPROTO_COMP    108           ! Compression Header Protocol.
CONSTANT: IPPROTO_RM      113           ! Reliable Multicast aka PGM
CONSTANT: IPPROTO_SCTP    132           ! Stream Control Transmission Protocol.
CONSTANT: IPPROTO_UDPLITE 136           ! UDP-Lite protocol.
CONSTANT: IPPROTO_MPLS    137           ! MPLS in IP.
CONSTANT: IPPROTO_RAW     255           ! Raw IP packets.

CONSTANT: FIOASYNC      0x8004667d
CONSTANT: FIONBIO       0x8004667e
CONSTANT: FIONREAD      0x4004667f

CONSTANT: IP_OPTIONS 1
CONSTANT: IP_HDRINCL 2
CONSTANT: IP_TOS 3
CONSTANT: IP_TTL 4
CONSTANT: IP_MULTICAST_IF 9
CONSTANT: IP_MULTICAST_TTL 10
CONSTANT: IP_MULTICAST_LOOP 11
CONSTANT: IP_ADD_MEMBERSHIP 12
CONSTANT: IP_DROP_MEMBERSHIP 13
CONSTANT: IP_DONTFRAGMENT 14
CONSTANT: IP_ADD_SOURCE_MEMBERSHIP 15
CONSTANT: IP_DROP_SOURCE_MEMBERSHIP 16
CONSTANT: IP_BLOCK_SOURCE 17
CONSTANT: IP_UNBLOCK_SOURCE 18
CONSTANT: IP_PKTINFO 19
CONSTANT: IP_RECEIVE_BROADCAST 22


CONSTANT: WSA_FLAG_OVERLAPPED 1
ALIAS: WSA_WAIT_EVENT_0 WAIT_OBJECT_0
ALIAS: WSA_MAXIMUM_WAIT_EVENTS MAXIMUM_WAIT_OBJECTS
CONSTANT: WSA_INVALID_EVENT f
CONSTANT: WSA_WAIT_FAILED -1
ALIAS: WSA_WAIT_IO_COMPLETION WAIT_IO_COMPLETION
ALIAS: WSA_WAIT_TIMEOUT WAIT_TIMEOUT
ALIAS: WSA_INFINITE INFINITE
ALIAS: WSA_IO_PENDING ERROR_IO_PENDING

CONSTANT: INADDR_ANY 0

: INVALID_SOCKET ( -- n ) -1 <alien> ; inline

: SOCKET_ERROR ( -- n ) -1 ; inline

CONSTANT: SD_RECV 0
CONSTANT: SD_SEND 1
CONSTANT: SD_BOTH 2

CONSTANT: SOL_SOCKET 0xffff

C-TYPE: sockaddr

STRUCT: sockaddr-in
    { family short }
    { port ushort }
    { addr uint }
    { pad char[8] } ;

STRUCT: sockaddr-in6
    { family uchar }
    { port ushort }
    { flowinfo uint }
    { addr uchar[16] }
    { scopeid uint } ;

STRUCT: hostent
    { name c-string }
    { aliases void* }
    { addrtype short }
    { length short }
    { addr-list void* } ;

STRUCT: protoent
    { name c-string }
    { aliases void* }
    { proto short } ;

STRUCT: addrinfo
    { flags int }
    { family int }
    { socktype int }
    { protocol int }
    { addrlen size_t }
    { canonname c-string }
    { addr sockaddr* }
    { next addrinfo* } ;

STRUCT: timeval
    { sec long }
    { usec long } ;

GENERIC: sockaddr>ip ( sockaddr -- string )

M: sockaddr-in sockaddr>ip
    addr>> uint <ref> [ number>string ] { } map-as "." join ;

M: sockaddr-in6 sockaddr>ip
    addr>> [ >hex ] { } map-as 2 group [ concat ] map ":" join ;

STRUCT: fd_set
    { fd_count uint }
    { fd_array SOCKET[64] } ;

LIBRARY: winsock

FUNCTION: int setsockopt ( SOCKET s, int level, int optname, c-string optval, int optlen )
FUNCTION: int ioctlsocket ( SOCKET s, long cmd, ulong* *argp )

FUNCTION: ushort htons ( ushort n )
FUNCTION: ushort ntohs ( ushort n )
FUNCTION: int bind ( SOCKET socket, sockaddr-in* sockaddr, int len )
FUNCTION: int listen ( SOCKET socket, int backlog )
FUNCTION: c-string inet_ntoa ( int in-addr )
FUNCTION: int getaddrinfo ( c-string nodename,
                            c-string servername,
                            addrinfo* hints,
                            addrinfo** res )

FUNCTION: void freeaddrinfo ( addrinfo* ai )


FUNCTION: hostent* gethostbyname ( c-string name )
FUNCTION: int gethostname ( c-string name, int len )
FUNCTION: SOCKET socket ( int domain, int type, int protocol )
FUNCTION: int connect ( SOCKET socket, sockaddr-in* sockaddr, int addrlen )
FUNCTION: int select ( int nfds, fd_set* readfds, fd_set* writefds, fd_set* exceptfds, timeval* timeout )
FUNCTION: int closesocket ( SOCKET s )
FUNCTION: int shutdown ( SOCKET s, int how )
FUNCTION: int send ( SOCKET s, c-string buf, int len, int flags )
FUNCTION: int recv ( SOCKET s, c-string buf, int len, int flags )

FUNCTION: int getsockname ( SOCKET s, sockaddr-in* address, int* addrlen )
FUNCTION: int getpeername ( SOCKET s, sockaddr-in* address, int* addrlen )

FUNCTION: protoent* getprotobyname ( c-string name )

FUNCTION: servent* getservbyname ( c-string name, c-string prot )
FUNCTION: servent* getservbyport ( int port, c-string prot )

TYPEDEF: uint SERVICETYPE
TYPEDEF: void* LPWSADATA
TYPEDEF: OVERLAPPED WSAOVERLAPPED
TYPEDEF: WSAOVERLAPPED* LPWSAOVERLAPPED
TYPEDEF: uint GROUP
TYPEDEF: void* LPCONDITIONPROC
TYPEDEF: HANDLE WSAEVENT
TYPEDEF: LPHANDLE LPWSAEVENT
TYPEDEF: sockaddr* LPSOCKADDR

STRUCT: FLOWSPEC
    { TokenRate          uint        }
    { TokenBucketSize    uint        }
    { PeakBandwidth      uint        }
    { Latency            uint        }
    { DelayVariation     uint        }
    { ServiceType        SERVICETYPE }
    { MaxSduSize         uint        }
    { MinimumPolicedSize uint        } ;
TYPEDEF: FLOWSPEC* PFLOWSPEC
TYPEDEF: FLOWSPEC* LPFLOWSPEC

STRUCT: WSABUF
    { len ulong }
    { buf void* } ;
TYPEDEF: WSABUF* LPWSABUF

STRUCT: QOS
    { SendingFlowspec FLOWSPEC }
    { ReceivingFlowspec FLOWSPEC }
    { ProviderSpecific WSABUF } ;
TYPEDEF: QOS* LPQOS

CONSTANT: MAX_PROTOCOL_CHAIN 7

STRUCT: WSAPROTOCOLCHAIN
    { ChainLen int }
    { ChainEntries { DWORD 7 } } ;
    ! { ChainEntries { DWORD MAX_PROTOCOL_CHAIN } } ;
TYPEDEF: WSAPROTOCOLCHAIN* LPWSAPROTOCOLCHAIN

CONSTANT: WSAPROTOCOL_LEN 255

STRUCT: WSAPROTOCOL_INFOW
    { dwServiceFlags1 DWORD }
    { dwServiceFlags2 DWORD }
    { dwServiceFlags3 DWORD }
    { dwServiceFlags4 DWORD }
    { dwProviderFlags DWORD }
    { ProviderId GUID }
    { dwCatalogEntryId DWORD }
    { ProtocolChain WSAPROTOCOLCHAIN }
    { iVersion int }
    { iAddressFamily int }
    { iMaxSockAddr int }
    { iMinSockAddr int }
    { iSocketType int }
    { iProtocol int }
    { iProtocolMaxOffset int }
    { iNetworkByteOrder int }
    { iSecurityScheme int }
    { dwMessageSize DWORD }
    { dwProviderReserved DWORD }
    { szProtocol { WCHAR 256 } } ;
    ! { szProtocol[WSAPROTOCOL_LEN+1] { WCHAR 256 } } ;
TYPEDEF: WSAPROTOCOL_INFOW* PWSAPROTOCOL_INFOW
TYPEDEF: WSAPROTOCOL_INFOW* LPWSAPROTOCOL_INFOW
TYPEDEF: WSAPROTOCOL_INFOW WSAPROTOCOL_INFO
TYPEDEF: WSAPROTOCOL_INFOW* PWSAPROTOCOL_INFO
TYPEDEF: WSAPROTOCOL_INFOW* LPWSAPROTOCOL_INFO


STRUCT: WSANAMESPACE_INFOW
    { NSProviderId   GUID    }
    { dwNameSpace    DWORD   }
    { fActive        BOOL    }
    { dwVersion      DWORD   }
    { lpszIdentifier LPWSTR  } ;
TYPEDEF: WSANAMESPACE_INFOW* PWSANAMESPACE_INFOW
TYPEDEF: WSANAMESPACE_INFOW* LPWSANAMESPACE_INFOW
TYPEDEF: WSANAMESPACE_INFOW WSANAMESPACE_INFO
TYPEDEF: WSANAMESPACE_INFO* PWSANAMESPACE_INFO
TYPEDEF: WSANAMESPACE_INFO* LPWSANAMESPACE_INFO

CONSTANT: FD_MAX_EVENTS 10

STRUCT: WSANETWORKEVENTS
    { lNetworkEvents long }
    { iErrorCode { int FD_MAX_EVENTS } } ;
TYPEDEF: WSANETWORKEVENTS* PWSANETWORKEVENTS
TYPEDEF: WSANETWORKEVENTS* LPWSANETWORKEVENTS

! STRUCT: WSAOVERLAPPED
    ! { Internal DWORD }
    ! { InternalHigh DWORD }
    ! { Offset DWORD }
    ! { OffsetHigh DWORD }
    ! { hEvent WSAEVENT }
    ! { bytesTransferred DWORD } ;
! TYPEDEF: WSAOVERLAPPED* LPWSAOVERLAPPED

FUNCTION: SOCKET WSAAccept ( SOCKET s,
                             sockaddr* addr,
                             LPINT addrlen,
                             LPCONDITIONPROC lpfnCondition,
                             DWORD dwCallbackData )

! FUNCTION: INT WSAAddressToString ( LPSOCKADDR lpsaAddress, DWORD dwAddressLength, LPWSAPROTOCOL_INFO lpProtocolInfo, LPTSTR lpszAddressString, LPDWORD lpdwAddressStringLength ) ;

FUNCTION: int WSACleanup ( )
FUNCTION: BOOL WSACloseEvent ( WSAEVENT hEvent )

FUNCTION: int WSAConnect ( SOCKET s,
                           sockaddr* name,
                           int namelen,
                           LPWSABUF lpCallerData,
                           LPWSABUF lpCalleeData,
                           LPQOS lpSQOS,
                           LPQOS lpGQOS )
FUNCTION: WSAEVENT WSACreateEvent ( )
! FUNCTION: INT WSAEnumNameSpaceProviders ( LPDWORD lpdwBufferLength, LPWSANAMESPACE_INFO lpnspBuffer ) ;
FUNCTION: int WSAEnumNetworkEvents ( SOCKET s,
                                     WSAEVENT hEventObject,
                                     LPWSANETWORKEVENTS lpNetworkEvents )
! FUNCTION: int WSAEnumProtocols ( LPINT lpiProtocols, LPWSAPROTOCOL_INFO lpProtocolBuffer, LPDWORD lpwdBufferLength ) ;

FUNCTION: int WSAEventSelect ( SOCKET s,
                               WSAEVENT hEventObject,
                               long lNetworkEvents )
FUNCTION: int WSAGetLastError ( )
FUNCTION: BOOL WSAGetOverlappedResult ( SOCKET s,
                                        LPWSAOVERLAPPED lpOverlapped,
                                        LPDWORD lpcbTransfer,
                                        BOOL fWait,
                                        LPDWORD lpdwFlags )

TYPEDEF: void* LPWSAOVERLAPPED_COMPLETION_ROUTINE
FUNCTION: int WSAIoctl ( SOCKET s,
                         DWORD dwIoControlCode,
                         LPVOID lpvInBuffer,
                         DWORD cbInBuffer,
                         LPVOID lpvOutBuffer,
                         DWORD cbOutBuffer,
                         LPDWORD lpcbBytesReturned,
                         LPWSAOVERLAPPED lpOverlapped,
                         LPWSAOVERLAPPED_COMPLETION_ROUTINE lpCompletionRoutine )

FUNCTION: int WSARecv ( SOCKET s,
                        LPWSABUF lpBuffers,
                        DWORD dwBufferCount,
                        LPDWORD lpNumberOfBytesRecvd,
                        LPDWORD lpFlags,
                        LPWSAOVERLAPPED lpOverlapped,
                        LPWSAOVERLAPPED_COMPLETION_ROUTINE lpCompletionRoutine )

FUNCTION: int WSARecvFrom ( SOCKET s,
                            LPWSABUF lpBuffers,
                            DWORD dwBufferCount,
                            LPDWORD lpNumberOfBytesRecvd,
                            LPDWORD lpFlags,
                            sockaddr* lpFrom,
                            LPINT lpFromlen,
                            LPWSAOVERLAPPED lpOverlapped,
                            LPWSAOVERLAPPED_COMPLETION_ROUTINE lpCompletionRoutine )

FUNCTION: BOOL WSAResetEvent ( WSAEVENT hEvent )
FUNCTION: int WSASend ( SOCKET s,
                        LPWSABUF lpBuffers,
                        DWORD dwBufferCount,
                        LPDWORD lpNumberOfBytesSent,
                        LPDWORD lpFlags,
                        LPWSAOVERLAPPED lpOverlapped,
                 LPWSAOVERLAPPED_COMPLETION_ROUTINE lpCompletionRoutine )

FUNCTION: int WSASendTo ( SOCKET s,
                          LPWSABUF lpBuffers,
                          DWORD dwBufferCount,
                          LPDWORD lpNumberOfBytesSent,
                          DWORD dwFlags,
                          sockaddr* lpTo,
                          int iToLen,
                          LPWSAOVERLAPPED lpOverlapped,
  LPWSAOVERLAPPED_COMPLETION_ROUTINE lpCompletionRoutine )

FUNCTION: int WSAStartup ( WORD version,  LPWSADATA out-data )

FUNCTION: SOCKET WSASocketW ( int af,
                             int type,
                             int protocol,
                             LPWSAPROTOCOL_INFOW lpProtocolInfo,
                             GROUP g,
                             DWORD flags )
ALIAS: WSASocket WSASocketW

FUNCTION: DWORD WSAWaitForMultipleEvents ( DWORD cEvents,
                                           WSAEVENT* lphEvents,
                                           BOOL fWaitAll,
                                           DWORD dwTimeout,
                                           BOOL fAlertable )


LIBRARY: mswsock

FUNCTION: int AcceptEx ( SOCKET listen,
                         SOCKET accept,
                         PVOID out-buf,
                         DWORD recv-len,
                         DWORD addr-len,
                         DWORD remote-len,
                         LPDWORD out-len,
                         LPOVERLAPPED overlapped )

FUNCTION: void GetAcceptExSockaddrs (
  PVOID lpOutputBuffer,
  DWORD dwReceiveDataLength,
  DWORD dwLocalAddressLength,
  DWORD dwRemoteAddressLength,
  LPSOCKADDR* LocalSockaddr,
  LPINT LocalSockaddrLength,
  LPSOCKADDR* RemoteSockaddr,
  LPINT RemoteSockaddrLength
)

CONSTANT: SIO_GET_EXTENSION_FUNCTION_POINTER -939524090

CONSTANT: WSAID_CONNECTEX GUID: {25a207b9-ddf3-4660-8ee9-76e58c74063e}

ERROR: winsock-exception n string ;

: winsock-expected-error? ( n -- ? )
    ${ ERROR_IO_PENDING ERROR_SUCCESS WSA_IO_PENDING } member? ;

: (maybe-winsock-exception) ( n -- winsock-exception/f )
    ! ! WSAStartup returns the error code 'n' directly
    dup winsock-expected-error?
    [ drop f ] [ [ ] [ n>win32-error-string ] bi \ winsock-exception boa ] if ;

: maybe-winsock-exception ( -- winsock-exception/f )
    WSAGetLastError (maybe-winsock-exception) ;

: winsock-error ( -- )
    maybe-winsock-exception [ throw ] when* ;

: (winsock-error) ( n -- * )
    [ ] [ n>win32-error-string ] bi winsock-exception ;

: throw-winsock-error ( -- * )
    WSAGetLastError (winsock-error) ;

: winsock-error=0/f ( n/f -- )
    { 0 f } member? [ winsock-error ] when ;

: winsock-error!=0/f ( n/f -- )
    { 0 f } member? [ winsock-error ] unless ;

! WSAStartup and WSACleanup return the error code directly
: winsock-return-check ( n/f -- )
    dup { 0 f } member? [
        drop
    ] [
        [ ] [ n>win32-error-string ] bi winsock-exception
    ] if ;

: socket-error* ( n -- )
    SOCKET_ERROR = [
        WSAGetLastError
        dup WSA_IO_PENDING = [
            drop
        ] [
            (maybe-winsock-exception) throw
        ] if
    ] when ;

: socket-error ( n -- )
    SOCKET_ERROR = [ winsock-error ] when ;

: init-winsock ( -- )
    0x0202 <wsadata> WSAStartup winsock-return-check ;

: shutdown-winsock ( -- ) WSACleanup winsock-return-check ;

STARTUP-HOOK: init-winsock
SHUTDOWN-HOOK: shutdown-winsock
