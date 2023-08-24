! Copyright (C) 2010 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types alien.data alien.syntax
classes.struct combinators combinators.smart destructors
io.encodings.string io.encodings.utf8 io.sockets.private kernel
libc make sequences windows.errors windows.kernel32
windows.types windows.winsock ;
IN: windows.iphlpapi

LIBRARY: iphlpapi

<<
CONSTANT: DEFAULT_MINIMUM_ENTITIES 32
CONSTANT: MAX_ADAPTER_ADDRESS_LENGTH 8
CONSTANT: MAX_ADAPTER_DESCRIPTION_LENGTH 128
CONSTANT: MAX_ADAPTER_NAME_LENGTH 256
CONSTANT: MAX_DOMAIN_NAME_LEN 128
CONSTANT: MAX_HOSTNAME_LEN 128
CONSTANT: MAX_SCOPE_ID_LEN 256
CONSTANT: BROADCAST_NODETYPE 1
CONSTANT: PEER_TO_PEER_NODETYPE 2
CONSTANT: MIXED_NODETYPE 4
CONSTANT: HYBRID_NODETYPE 8
CONSTANT: IF_OTHER_ADAPTERTYPE 0
CONSTANT: IF_ETHERNET_ADAPTERTYPE 1
CONSTANT: IF_TOKEN_RING_ADAPTERTYPE 2
CONSTANT: IF_FDDI_ADAPTERTYPE 3
CONSTANT: IF_PPP_ADAPTERTYPE 4
CONSTANT: IF_LOOPBACK_ADAPTERTYPE 5
>>

CONSTANT: MAX_DOMAIN_NAME_LEN+4 132
CONSTANT: MAX_HOSTNAME_LEN+4 132
CONSTANT: MAX_SCOPE_ID_LEN+4 260
CONSTANT: MAX_ADAPTER_NAME_LENGTH+4 264
CONSTANT: MAX_ADAPTER_DESCRIPTION_LENGTH+4 136
CONSTANT: ERROR_BUFFER_OVERFLOW 111
CONSTANT: MIB_IF_TYPE_ETHERNET 6
CONSTANT: MIB_IF_TYPE_TOKENRING 9
CONSTANT: MIB_IF_TYPE_FDDI 15
CONSTANT: MIB_IF_TYPE_PPP 23
CONSTANT: MIB_IF_TYPE_LOOPBACK 24
CONSTANT: MIB_IF_TYPE_SLIP 28
CONSTANT: MAX_DNS_SUFFIX_STRING_LENGTH 256 ! 246?
CONSTANT: MAX_DHCPV6_DUID_LENGTH 130
CONSTANT: MAX_ADAPTER_NAME 128

<<
STRUCT: IP_ADDRESS_STRING
    { String char[16] } ;
>>

TYPEDEF: IP_ADDRESS_STRING* PIP_ADDRESS_STRING
TYPEDEF: IP_ADDRESS_STRING IP_MASK_STRING
TYPEDEF: IP_MASK_STRING* PIP_MASK_STRING

<<
STRUCT: IP_ADDR_STRING
    { Next IP_ADDR_STRING* }
    { IpAddress IP_ADDRESS_STRING }
    { IpMask IP_MASK_STRING }
    { Context DWORD } ;
>>
TYPEDEF: IP_ADDR_STRING* PIP_ADDR_STRING

STRUCT: FIXED_INFO
    { HostName char[MAX_HOSTNAME_LEN+4] }
    { DomainName char[MAX_DOMAIN_NAME_LEN+4] }
    { CurrentDnsServer PIP_ADDR_STRING }
    { DnsServerList IP_ADDR_STRING }
    { NodeType UINT }
    { ScopeId char[MAX_SCOPE_ID_LEN+4] }
    { EnableRouting UINT }
    { EnableProxy UINT }
    { EnableDns UINT }
    { ExtraSpace char[4096] } ;

DEFER: IP_ADAPTER_INFO

TYPEDEF: ulong time_t
TYPEDEF: uchar UINT8
TYPEDEF: uint NET_IF_COMPARTMENT_ID
TYPEDEF: GUID NET_IF_NETWORK_GUID

ENUM: IP_DAD_STATE
  IpDadStateInvalid
  IpDadStateTentative,
  IpDadStateDuplicate,
  IpDadStateDeprecated,
  IpDadStatePreferred ;

ENUM: IP_PREFIX_ORIGIN
    IpPrefixOriginOther,
    IpPrefixOriginManual,
    IpPrefixOriginWellKnown,
    IpPrefixOriginDhcp,
    IpPrefixOriginRouterAdvertisement,
    { IpPrefixOriginUnchanged 16 } ;

ENUM: IP_SUFFIX_ORIGIN
    IpSuffixOriginOther
    IpSuffixOriginManual,
    IpSuffixOriginWellKnown,
    IpSuffixOriginDhcp,
    IpSuffixOriginLinkLayerAddress,
    IpSuffixOriginRandom,
    { IpSuffixOriginUnchanged 16 } ;

ENUM: IF_OPER_STATUS
    { IfOperStatusUp 1 }
    IfOperStatusDown,
    IfOperStatusTesting,
    IfOperStatusUnknown,
    IfOperStatusDormant,
    IfOperStatusNotPresent,
    IfOperStatusLowerLayerDown ;

ENUM: NET_IF_CONNECTION_TYPE
    { NET_IF_CONNECTION_DEDICATED 1 }
    NET_IF_CONNECTION_PASSIVE,
    NET_IF_CONNECTION_DEMAND,
    NET_IF_CONNECTION_MAXIMUM ;


ENUM: TUNNEL_TYPE
    TUNNEL_TYPE_NONE,
    TUNNEL_TYPE_OTHER,
    TUNNEL_TYPE_DIRECT,
    TUNNEL_TYPE_6TO4,
    TUNNEL_TYPE_ISATAP,
    TUNNEL_TYPE_TEREDO,
    TUNNEL_TYPE_IPHTTPS ;



STRUCT: SOCKET_ADDRESS
    { lpSockaddr LPSOCKADDR }
    { iSockaddrLength INT } ;

ERROR: unknown-sockaddr-length sockaddr length ;

: SOCKET_ADDRESS>sockaddr ( obj -- sockaddr )
    dup iSockaddrLength>> {
        { 16 [ lpSockaddr>> sockaddr-in memory>struct ] }
        { 28 [ lpSockaddr>> sockaddr-in6 memory>struct ] }
        [ unknown-sockaddr-length ]
    } case ;

TYPEDEF: SOCKET_ADDRESS* PSOCKET_ADDRESS

STRUCT: IP_ADAPTER_INFO
    { Next IP_ADAPTER_INFO* }
    { ComboIndex DWORD }
    { AdapterName char[MAX_ADAPTER_NAME_LENGTH+4] }
    { Description char[MAX_ADAPTER_DESCRIPTION_LENGTH+4] }
    { AddressLength UINT }
    { Address BYTE[MAX_ADAPTER_ADDRESS_LENGTH] }
    { Index DWORD }
    { Type UINT }
    { DhcpEnabled UINT }
    { CurrentIpAddress PIP_ADDR_STRING }
    { IpAddressList IP_ADDR_STRING }
    { GatewayList IP_ADDR_STRING }
    { DhcpServer IP_ADDR_STRING }
    { HaveWins BOOL }
    { PrimaryWinsServer IP_ADDR_STRING }
    { SecondaryWinsServer IP_ADDR_STRING }
    { LeaseObtained time_t }
    { LeaseExpires time_t } ;

TYPEDEF: IP_ADAPTER_INFO* PIP_ADAPTER_INFO

STRUCT: LengthIndex
    { Length ULONG }
    { IfIndex DWORD } ;

TYPEDEF: LengthIndex LengthFlags

UNION-STRUCT: AlignmentLenIndex
    { Alignment ULONGLONG }
    { LenIndex LengthIndex } ;

UNION-STRUCT: AlignmentLenFlags
    { Alignment ULONGLONG }
    { LenFlags LengthFlags } ;

STRUCT: ResNetIf
    { Reserved ULONG64 bits: 24 }
    { NetLuidIndex ULONG64 bits: 24 }
    { IfType ULONG64 bits: 16 } ;

UNION-STRUCT: NET_LUID
    { Value ULONG64 }
    { Info ResNetIf } ;

TYPEDEF: NET_LUID* PNET_LUID
TYPEDEF: NET_LUID IF_LUID

DEFER: IP_ADAPTER_ADDRESSES
DEFER: IP_ADAPTER_UNICAST_ADDRESS
STRUCT: IP_ADAPTER_UNICAST_ADDRESS
    { Header LengthFlags }
    { Next IP_ADAPTER_UNICAST_ADDRESS* }
    { Address SOCKET_ADDRESS }
    { PrefixOrigin IP_PREFIX_ORIGIN }
    { SuffixOrigin IP_SUFFIX_ORIGIN }
    { DadState IP_DAD_STATE }
    { ValidLifetime ULONG }
    { PreferredLifetime ULONG }
    { LeaseLifeTime ULONG }
    { OnLinkPrefixLength UINT8 } ;

TYPEDEF: IP_ADAPTER_UNICAST_ADDRESS* PIP_ADAPTER_UNICAST_ADDRESS

DEFER: IP_ADAPTER_ANYCAST_ADDRESS
STRUCT: IP_ADAPTER_ANYCAST_ADDRESS
    { Header AlignmentLenFlags }
    { Next IP_ADAPTER_ANYCAST_ADDRESS* }
    { Address SOCKET_ADDRESS } ;

TYPEDEF: IP_ADAPTER_ANYCAST_ADDRESS* PIP_ADAPTER_ANYCAST_ADDRESS


DEFER: IP_ADAPTER_MULTICAST_ADDRESS
STRUCT: IP_ADAPTER_MULTICAST_ADDRESS
    { Header AlignmentLenFlags }
    { Next IP_ADAPTER_MULTICAST_ADDRESS* }
    { Address SOCKET_ADDRESS } ;

TYPEDEF: IP_ADAPTER_MULTICAST_ADDRESS* PIP_ADAPTER_MULTICAST_ADDRESS


DEFER: IP_ADAPTER_DNS_SERVER_ADDRESS
STRUCT: IP_ADAPTER_DNS_SERVER_ADDRESS
    { Header AlignmentLenFlags }
    { Next IP_ADAPTER_DNS_SERVER_ADDRESS* }
    { Address SOCKET_ADDRESS } ;

TYPEDEF: IP_ADAPTER_DNS_SERVER_ADDRESS* PIP_ADAPTER_DNS_SERVER_ADDRESS


DEFER: IP_ADAPTER_WINS_SERVER_ADDRESS
STRUCT: IP_ADAPTER_WINS_SERVER_ADDRESS
    { Header AlignmentLenFlags }
    { Next IP_ADAPTER_WINS_SERVER_ADDRESS* }
    { Address SOCKET_ADDRESS } ;

TYPEDEF: IP_ADAPTER_WINS_SERVER_ADDRESS* PIP_ADAPTER_WINS_SERVER_ADDRESS

TYPEDEF: IP_ADAPTER_WINS_SERVER_ADDRESS* PIP_ADAPTER_WINS_SERVER_ADDRESS_LH



DEFER: IP_ADAPTER_GATEWAY_ADDRESS
STRUCT: IP_ADAPTER_GATEWAY_ADDRESS
    { Header AlignmentLenFlags }
    { Next IP_ADAPTER_GATEWAY_ADDRESS* }
    { Address SOCKET_ADDRESS } ;

TYPEDEF: IP_ADAPTER_GATEWAY_ADDRESS* PIP_ADAPTER_GATEWAY_ADDRESS

TYPEDEF: IP_ADAPTER_GATEWAY_ADDRESS* PIP_ADAPTER_GATEWAY_ADDRESS_LH

DEFER: IP_ADAPTER_PREFIX
STRUCT: IP_ADAPTER_PREFIX
    { Header AlignmentLenFlags }
    { Next IP_ADAPTER_PREFIX* }
    { Address SOCKET_ADDRESS }
    { PrefixLength ULONG } ;

TYPEDEF: IP_ADAPTER_PREFIX* PIP_ADAPTER_PREFIX


DEFER: IP_ADAPTER_DNS_SUFFIX
STRUCT: IP_ADAPTER_DNS_SUFFIX
    { Next IP_ADAPTER_DNS_SUFFIX* }
    { String WCHAR[MAX_DNS_SUFFIX_STRING_LENGTH] } ;

TYPEDEF: IP_ADAPTER_DNS_SUFFIX* PIP_ADAPTER_DNS_SUFFIX


CONSTANT: GAA_FLAG_SKIP_UNICAST 0x0001
CONSTANT: GAA_FLAG_SKIP_ANYCAST 0x0002
CONSTANT: GAA_FLAG_SKIP_MULTICAST 0x0004
CONSTANT: GAA_FLAG_SKIP_DNS_SERVER 0x0008
CONSTANT: GAA_FLAG_INCLUDE_PREFIX 0x0010
CONSTANT: GAA_FLAG_SKIP_FRIENDLY_NAME 0x0020
CONSTANT: GAA_FLAG_INCLUDE_WINS_INFO 0x0040
CONSTANT: GAA_FLAG_INCLUDE_GATEWAYS 0x0080
CONSTANT: GAA_FLAG_INCLUDE_ALL_INTERFACES 0x0100
CONSTANT: GAA_FLAG_INCLUDE_ALL_COMPARTMENTS 0x0200
CONSTANT: GAA_FLAG_INCLUDE_TUNNEL_BINDINGORDER 0x0400

STRUCT: IP_ADAPTER_ADDRESSES
    { Header AlignmentLenIndex }
    { Next IP_ADAPTER_ADDRESSES* }
    { AdapterName PCHAR }
    { FirstUnicastAddress PIP_ADAPTER_UNICAST_ADDRESS }
    { FirstAnycastAddress PIP_ADAPTER_ANYCAST_ADDRESS }
    { FirstMulticastAddress PIP_ADAPTER_MULTICAST_ADDRESS }
    { FirstDnsServerAddress PIP_ADAPTER_DNS_SERVER_ADDRESS }
    { DnsSuffix PWCHAR }
    { Description PWCHAR }
    { FriendlyName PWCHAR }
    { PhysicalAddress BYTE[MAX_ADAPTER_ADDRESS_LENGTH] }
    { PhysicalAddressLength DWORD }
    { Flags DWORD }
    { Mtu DWORD }
    { IfType DWORD }
    { OperStatus IF_OPER_STATUS }
    { Ipv6IfIndex DWORD }
    { ZoneIndices DWORD[16] }
    { FirstPrefix PIP_ADAPTER_PREFIX }
    { TransmitLinkSpeed ULONG64 }
    { ReceiveLinkSpeed ULONG64 }
    { FirstWinsServerAddress PIP_ADAPTER_WINS_SERVER_ADDRESS_LH }
    { FirstGatewayAddress PIP_ADAPTER_GATEWAY_ADDRESS_LH }
    { Ipv4Metric ULONG }
    { Ipv6Metric ULONG }
    { Luid IF_LUID }
    { Dhcpv4Server SOCKET_ADDRESS }
    { CompartmentId NET_IF_COMPARTMENT_ID }
    { NetworkGuid NET_IF_NETWORK_GUID }
    { ConnectionType NET_IF_CONNECTION_TYPE }
    { TunnelType TUNNEL_TYPE }
    { Dhcpv6Server SOCKET_ADDRESS }
    { Dhcpv6ClientDuid BYTE[MAX_DHCPV6_DUID_LENGTH] }
    { Dhcpv6ClientDuidLength ULONG }
    { Dhcpv6Iaid ULONG }
    { FirstDnsSuffix PIP_ADAPTER_DNS_SUFFIX } ;

TYPEDEF: IP_ADAPTER_ADDRESSES* PIP_ADAPTER_ADDRESSES

TYPEDEF: FIXED_INFO* PFIXED_INFO

STRUCT: S_un_b
    { s_b1 uchar }
    { s_b2 uchar }
    { s_b3 uchar }
    { s_b4 uchar } ;

STRUCT: S_un_w
    { s_w1 ushort }
    { s_w2 ushort } ;

UNION-STRUCT: IPAddr
    { S_un_b S_un_b }
    { S_un_w S_un_w }
    { S_addr ulong } ;

UNION-STRUCT: S_un
    { S_un_b S_un_b }
    { S_un_w S_un_w }
    { S_addr ulong } ;

STRUCT: IP_ADAPTER_INDEX_MAP
    { Index ULONG }
    { Name WCHAR[MAX_ADAPTER_NAME] } ;
TYPEDEF: IP_ADAPTER_INDEX_MAP* PIP_ADAPTER_INDEX_MAP

FUNCTION: DWORD IpReleaseAddress ( PIP_ADAPTER_INDEX_MAP AdapterInfo )
FUNCTION: DWORD IpRenewAddress ( PIP_ADAPTER_INDEX_MAP AdapterInfo )


FUNCTION: DWORD GetBestInterface (
   IPAddr dwDestAddr,
   PDWORD pdwBestIfIndex
)

FUNCTION: DWORD GetBestInterfaceEx (
    sockaddr* pDestAddr,
    PDWORD pdwBestIfIndex
)

FUNCTION: ULONG GetAdaptersAddresses (
    ULONG Family,
    ULONG Flags,
    PVOID Reserved,
    PIP_ADAPTER_ADDRESSES AdapterAddresses,
    PULONG SizePointer
)

! Deprecated
FUNCTION: DWORD GetAdaptersInfo (
    PIP_ADAPTER_INFO pAdapterInfo,
    PULONG pOutBufLen )

FUNCTION: DWORD GetNetworkParams ( PFIXED_INFO pFixedInfo, PULONG pOutBufLen )

: get-fixed-info ( -- FIXED_INFO )
    FIXED_INFO new dup byte-length ulong <ref>
    [ GetNetworkParams n>win32-error-check ] keepd ;

: dns-server-ips ( -- sequence )
    get-fixed-info DnsServerList>> [
        [
            [ IpAddress>> String>> [ 0 = ] trim-tail utf8 decode , ]
            [ Next>> ] bi dup
        ] loop drop
    ] { } make ;


! second struct starts at 720h


<PRIVATE

: loop-list ( obj -- seq )
    [ Next>> ] follow ;

! Don't use this, use each/map-adapters
: iterate-interfaces ( -- seq )
    AF_UNSPEC GAA_FLAG_INCLUDE_PREFIX 0 uint <ref>
    65,536 [ malloc &free ] [ ULONG <ref> ] bi
    [ GetAdaptersAddresses win32-error=0/f ] 2keep
    uint deref drop
    IP_ADAPTER_ADDRESSES memory>struct loop-list ;

PRIVATE>

: interfaces-each ( quot -- seq )
    [ [ iterate-interfaces ] dip each ] with-destructors ; inline

: interfaces-map ( quot -- seq )
    [ [ iterate-interfaces ] dip { } map-as ] with-destructors ; inline

: interface-mac-addrs ( -- seq )
    [
        {
            [ Description>> ]
            [ [ PhysicalAddress>> ] [ PhysicalAddressLength>> ] bi head ]
        } cleave>array
    ] interfaces-map ;

: interface-ips ( -- seq )
    [
        {
            [ Description>> ]
            [ FirstUnicastAddress>> loop-list [ Address>> SOCKET_ADDRESS>sockaddr sockaddr>ip ] map ]
        } cleave>array
    ] interfaces-map ;

: get-best-interface ( inet -- interface )
    make-sockaddr 0 DWORD <ref>
    [ GetBestInterfaceEx win32-error=0/f ] keep DWORD deref ;
