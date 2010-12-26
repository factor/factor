! Copyright (C) 2010 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types alien.data alien.syntax
classes.struct io.encodings.string io.encodings.utf8 kernel
make sequences windows.errors windows.types ;
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

STRUCT: IP_ADDRESS_STRING
    { String char[16] } ;

TYPEDEF: IP_ADDRESS_STRING* PIP_ADDRESS_STRING
TYPEDEF: IP_ADDRESS_STRING IP_MASK_STRING
TYPEDEF: IP_MASK_STRING* PIP_MASK_STRING

STRUCT: IP_ADDR_STRING
    { Next IP_ADDR_STRING* }
    { IpAddress IP_ADDRESS_STRING }
    { IpMask IP_MASK_STRING }
    { Context DWORD } ;
    
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

TYPEDEF: FIXED_INFO* PFIXED_INFO

FUNCTION: DWORD GetNetworkParams ( PFIXED_INFO pFixedInfo, PULONG pOutBufLen ) ;

: get-fixed-info ( -- FIXED_INFO )
    FIXED_INFO <struct> dup byte-length ulong <ref>
    [ GetNetworkParams n>win32-error-check ] 2keep drop ;
    
: dns-server-ips ( -- sequence )
    get-fixed-info DnsServerList>> [
        [
            [ IpAddress>> String>> [ 0 = ] trim-tail utf8 decode , ]
            [ Next>> ] bi dup
        ] loop drop
    ] { } make ;
