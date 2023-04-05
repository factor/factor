! File: pcap.factor
! Version: 0.1
! DRI: Dave Carlton <davec@polymicro.net>
! Description: Vocabulary to read pcap files created by tcpdump.
! Copyright (C) 2013 Dave Carlton
! See http://factorcode.org/license.txt for BSD license.

USING: accessors alien alien.accessors alien.c-types alien.endian
alien.libraries alien.syntax classes.struct combinators io
io.encodings.binary io.files kernel libc namespaces struct system
variables ;

IN: pcap

TYPEDEF: uint in_addr_t

BE-PACKED-STRUCT: be-in_addr
{ s_addr uint }
;

BE-PACKED-STRUCT: be-header
{ src uchar[6] }
{ dst uchar[6] }
{ type ushort }
;

BE-PACKED-STRUCT: be-ip
{ src uchar[6] }
{ dst uchar[6] }
{ type ushort }
{ ip_v uint bits: 4 }
{ ip_hl uint bits: 4 }
{ ip_tos uchar }
{ ip_len ushort }
{ ip_id ushort }
{ ip_ttl uchar }
{ ip_p uchar }
{ ip_char ushort }
{ ip_src uint }
{ ip_dst uint }
;

BE-PACKED-STRUCT: be-pcap-header
{ pcap_magic uint }
{ pcap_vmajor ushort }
{ pcap_vminor ushort }
{ pcap_zoff uint }
{ pcap_tsa uint }
{ pcap_snaplen uint }
{ pcap_headtype uint }
;

LE-PACKED-STRUCT: le-in_addr
{ s_addr uint }
;

LE-PACKED-STRUCT: le-header
{ src uchar[6] }
{ dst uchar[6] }
{ type ushort }
;

LE-PACKED-STRUCT: le-ip
{ src uchar[6] }
{ dst uchar[6] }
{ type ushort }
{ ip_v uint bits: 4 }
{ ip_hl uint bits: 4 }
{ ip_tos uchar }
{ ip_len ushort }
{ ip_id ushort }
{ ip_ttl uchar }
{ ip_p uchar }
{ ip_char ushort }
{ ip_src uint }
{ ip_dst uint }
;

LE-PACKED-STRUCT: le-pcap-header
{ pcap_magic uint }
{ pcap_vmajor ushort }
{ pcap_vminor ushort }
{ pcap_zoff uint }
{ pcap_tsa uint }
{ pcap_snaplen uint }
{ pcap_linktype uint }
;

VAR: pcap-filereader

TUPLE: pcapfile  path filereader byteorder ;

PRIVATE>
CONSTANT: be-magic 0xa1b2c3d4
CONSTANT: le-magic 0xd4c3b2a1

: be? ( B{} -- boolean )
    0 alien-unsigned-4  be-magic = ;

: read-magic ( pcapfile -- B{} )
    filereader>> [ 4 read ] with-input-stream ;

: pcap-byteorder! ( pcapfile -- )
    dup  read-magic be? >>byteorder  drop ;

: pcap-reset ( pcapfile -- )
    dup path>> binary <file-reader> >>filereader
    set: pcap-filereader ;
PRIVATE>

: <pcapfile> ( path -- )
    pcapfile new
    swap >>path  pcap-reset
    pcap-filereader pcap-byteorder! ;

: pcap-filereader@ (  -- filereader )
    pcap-filereader dup
    filereader>> disposed>>
    [ dup pcap-reset ] when
    filereader>> ;

: with-pcapfile ( quot -- )
    pcap-filereader@ swap with-input-stream ; inline

: pcap-header ( -- struct )
    pcap-filereader byteorder>>
    [ le-pcap-header ] [ be-pcap-header ] if ;

: pcap-header@ ( -- <pcap-header> )
    [ pcap-header sizeof read ] with-pcapfile
    pcap-header memory>struct ;

<< "pcap" {
    { [ os macosx? ] [ "libpcap.dylib" cdecl add-library ] }
    { [ os windows? ] [ "pcap.dll" cdecl add-library ] }
    [ drop ]
} cond >>

LIBRARY: pcaplib

CONSTANT: PCAP_ERRBUF_SIZE 256
VAR: testfile 
VAR: errstring 
VAR: fp
VAR: pcapFILE

! int pcap_findalldevs_ex	( 	char * 	  host,
! char * 	  port,
! SOCKET 	  sockctrl,
! struct pcap_rmtauth * 	  auth,
! pcap_if_t ** 	  alldevs,
! char * 	  errbuf
! ) 	
TYPEDEF: int SOCKET
STRUCT: pcap_rmtauth
{ type int }
{ username char* }
{ password char* }
;

STRUCT: sockaddr 
    { sa_family short }
    { sa_data char[14] }
    ;

STRUCT: pcap_addr 
    { next pcap_addr* }
    { addr sockaddr* }
    { netmask sockaddr* }
    { broadaddr sockaddr* }
    { dstaddr sockaddr* }
    ;

TYPEDEF: uint bpf_u_int32
STRUCT: pcap_if 
    { next pcap_if* }
    { name char* }
    { description char* }
    { addresses pcap_addr*  }
    { flags bpf_u_int32 }
    ;

TYPEDEF: pcap_if* pcap_if_t

STRUCT: pcap_stat_ex
{ rx_packets ulong }
{ tx_packets ulong }
{ rx_bytes ulong } 
{ tx_bytes ulong } 
{ rx_errors ulong }
{ tx_errors ulong }
{ rx_dropped ulong }
{ tx_dropped ulong }
{ multicast ulong } 
{ collisions ulong }
{ rx_length_errors ulong }
{ rx_over_errors ulong }
{ rx_crc_errors ulong } 
{ rx_frame_errors ulong }
{ rx_fifo_errors ulong } 
{ rx_missed_errors ulong }
{ tx_aborted_errors ulong }
{ tx_carrier_errors ulong }
{ tx_fifo_errors ulong }
{ tx_heartbeat_errors ulong }
{ tx_window_errors ulong }
;

FUNCTION: int pcap_findalldevs_ex ( c-string host, c-string port, SOCKET sockctrl, pcap_rmtauth* auth, pcap_if_t* alldevs, char* errbuf ) ;

! pcap_t *pcap_open_offline(const char *fname, char *errbuf);
TYPEDEF: void* pcap_t
FUNCTION: pcap_t pcap_open_offline ( c-string fname char* errbuf ) ;

! FILE *pcap_file(pcap_t *p);
TYPEDEF: void* FILE_ptr
FUNCTION: FILE_ptr pcap_file ( pcap_t *p ) ;

! const u_char *pcap_next(pcap_t *p, struct pcap_pkthdr *h);
PACKED-STRUCT: pcap_pkthdr
{ pcap_magic uint }
{ pcap_vmajor ushort }
{ pcap_vminor ushort }
{ pcap_zoff uint }
{ pcap_tsa uint }
{ pcap_snaplen uint }
{ pcap_linktype uint }
;

FUNCTION: void* pcap_next ( pcap_t* p, pcap_pkthdr* h ) ;

! int pcap_next_ex(pcap_t *p, struct pcap_pkthdr **pkt_header,  const u_char **pkt_data);
TYPEDEF: char* pktdata
TYPEDEF: pcap_pkthdr* pkthdr
FUNCTION: int pcap_next_ex ( pcap_t* fp, pkthdr* pkt_header, pktdata* pkt_data ) ;

! int pcap_snapshot(pcap_t *p);
FUNCTION: int pcap_snapshot ( pcap_t *p ) ;

! void pcap_close(pcap_t *p);
FUNCTION: void pcap_close ( pcap_t *p ) ;

: setup-read ( -- )
    "/Users/davec/Desktop/9997.dmp" set: testfile
    PCAP_ERRBUF_SIZE malloc  set: errstring
    testfile errstring pcap_open_offline  set: fp
    fp pcap_file  set: pcapFILE ;

VAR: next-header
: next ( -- x )
!    pcap_pkthdr malloc-struct set: next-header
    pcap_pkthdr heap-size malloc set: next-header
    fp next-header pcap_next ;