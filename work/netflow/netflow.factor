! File: netflow.factor
! Version: 0.1
! DRI: Dave Carlton
! Description: Another fine Factor file!
! Copyright (C) 2013 Dave Carlton.
! See http://factorcode.org/license.txt for BSD license.

USING: accessors alien.c-types alien.endian arrays assocs calendar
classes.struct cocoa cocoa.classes continuations destructors
formatting io io.encodings.binary io.files io.sockets io.timeouts
kernel math namespaces sequences splitting ;

IN: netflow

TUPLE: nf version count sysuptime timestamp flowsequence ;
TUPLE: nf5 < nf eniginetype engineid samplemode pdus ;
TUPLE: nf9 < nf flowsetid length templateid fieldcount fields ;
TUPLE: pdu srcaddr dstaddr nexthop inputint outputint packets octets duration srcport dstport
             pad0 tcpflags protocol tos srcas dstas srcmask stmask pad1 ;
TUPLE: field-definition type value length description ;
: <field-definition> ( type value length description -- field-definition )
    field-definition boa ;

SYMBOL: field-definitions
{ }
"IN_BYTES"                        1     4    "Incoming counter with length N x 8 bits for number of bytes associated with an IP Flow."  <field-definition> suffix
"IN_PKTS"                         2     4    "Incoming counter with length N x 8 bits for the number of packets associated with an IP Flow" <field-definition> suffix
"FLOWS"                           3     4    "Number of flows that were aggregated; default for N is 4" <field-definition> suffix
"PROTOCOL"                        4     1    "IP protocol byte" <field-definition> suffix
"SRC_TOS"                         5     1    "Type of Service byte setting when entering incoming interface" <field-definition> suffix
"TCP_FLAGS"                       6     1    "Cumulative of all the TCP flags seen for this flow" <field-definition> suffix
"L4_SRC_PORT"                     7     2    "TCP/UDP source port number i.e.: FTP, Telnet, or equivalent" <field-definition> suffix
"IPV4_SRC_ADDR"                   8     4    "IPv4 source address" <field-definition> suffix
"SRC_MASK"                        9     1    "The number of contiguous bits in the source address subnet mask i.e.: the submask in slash notation￼" <field-definition> suffix
"INPUT_SNMP"                      10    2    "Input interface index; default for N is 2 but higher values could be used" <field-definition> suffix
"L4_DST_PORT"                     11    2    "TCP/UDP destination port number i.e.: FTP, Telnet, or equivalent" <field-definition> suffix
"IPV4_DST_ADDR"                   12    4    "IPv4 destination address" <field-definition> suffix
"DST_MASK"                        13    1    "The number of contiguous bits in the destination address subnet mask i.e.: the submask in slash notation" <field-definition> suffix
"OUTPUT_SNMP"                     14    2    "Output interface index; default for N is 2 but higher values could be used" <field-definition> suffix
"IPV4_NEXT_HOP"                   15    4    "IPv4 address of next-hop router" <field-definition> suffix
"SRC_AS"                          16    2    "Source BGP autonomous system number where N could be 2 or 4" <field-definition> suffix
"DST_AS"                          17    2    "Destination BGP autonomous system number where N could be 2 or 4" <field-definition> suffix
"BGP_IPV4_NEXT_HOP"               18    4    "Next-hop router's IP in the BGP domain" <field-definition> suffix
"MUL_DST_PKTS"                    19    4    "IP multicast outgoing packet counter with length N x 8 bits for packets associated with the IP Flow" <field-definition> suffix
"MUL_DST_BYTES"                   20    4    "IP multicast outgoing byte counter with length N x 8 bits for bytes associated with the IP Flow" <field-definition> suffix
"LAST_SWITCHED"                   21    4    "System uptime at which the last packet of this flow was switched" <field-definition> suffix
"FIRST_SWITCHED"                  22    4    "System uptime at which the first packet of this flow was switched" <field-definition> suffix
"OUT_BYTES"                       23    4    "Outgoing counter with length N x 8 bits for the number of bytes associated with an IP Flow" <field-definition> suffix
"OUT_PKTS"                        24    4    "Outgoing counter with length N x 8 bits for the number of packets associated with an IP Flow." <field-definition> suffix
"MIN_PKT_LNGTH"                   25    2    "Minimum IP packet length on incoming packets of the flow" <field-definition> suffix
"MAX_PKT_LNGTH"                   26    2    "Maximum IP packet length on incoming packets of the flow" <field-definition> suffix
"IPV6_SRC_ADDR"                   27    16   "IPv6 Source Address" <field-definition> suffix
"IPV6_DST_ADDR"                   28    16   "IPv6 Destination Address" <field-definition> suffix
"IPV6_SRC_MASK"                   29    1    "Length of the IPv6 source mask in contiguous bits" <field-definition> suffix
"IPV6_DST_MASK"                   30    1    "Length of the IPv6 destination mask in contiguous bits" <field-definition> suffix
"IPV6_FLOW_LABEL"                 31    3    "IPv6 flow label as per RFC 2460 definition" <field-definition> suffix
"ICMP_TYPE"                       32    2    "Internet Control Message Protocol (ICMP) packet type; reported as ((ICMP Type * 256) + ICMP code)" <field-definition> suffix
"MUL_IGMP_TYPE"                   33    1    "Internet Group Management Protocol (IGMP) packet type" <field-definition> suffix
"SAMPLING_INTERVAL"               34    4    "When using sampled NetFlow, the rate at which packets are sampled e.g. a value of 100 indicates that one of every 100 packets is sampled" <field-definition> suffix
"SAMPLING_ALGORITHM"              35    1    "The type of algorithm used for sampled NetFlow: 0x01 Deterministic Sampling ,0x02 Random Sampling" <field-definition> suffix
"FLOW_ACTIVE_TIMEOUT"             36    2    "Timeout value (in seconds) for active flow entries in the NetFlow cache" <field-definition> suffix
"FLOW_INACTIVE_TIMEOUT"           37    2    "Timeout value (in seconds) for inactive flow entries in the NetFlow cache" <field-definition> suffix
"ENGINE_TYPE"                     38    1    "Type of flow switching engine: RP = 0, VIP/Linecard = 1" <field-definition> suffix
"ENGINE_ID"                       39    1    "ID number of the flow switching engine" <field-definition> suffix
"TOTAL_BYTES_EXP"                 40    4    "Counter with length N x 8 bits for bytes for the number of bytes exported by the Observation Domain" <field-definition> suffix
"TOTAL_PKTS_EXP"                  41    4    "Counter with length N x 8 bits for bytes for the number of packets exported by the Observation Domain" <field-definition> suffix
"TOTAL_FLOWS_EXP"                 42    4    "Counter with length N x 8 bits for bytes for the number of flows exported by the Observation Domain" <field-definition> suffix
"Vendor_0"                        43    0    "" <field-definition> suffix
"IPV4_SRC_PREFIX"                 44    4    "IPv4 source address prefix (specific for Catalyst architecture)" <field-definition> suffix
"IPV4_DST_PREFIX"                 45    4    "IPv4 destination address prefix (specific for Catalyst architecture)" <field-definition> suffix
"MPLS_TOP_LABEL_TYPE"             46    1    "MPLS Top Label Type: 0x00 UNKNOWN 0x01 TE-MIDPT 0x02 ATOM 0x03 VPN 0x04 BGP 0x05 LDP" <field-definition> suffix
"MPLS_TOP_LABEL_IP_ADDR"          47    4    "Forwarding Equivalent Class corresponding to the MPLS Top Label" <field-definition> suffix
"FLOW_SAMPLER_ID"                 48    1    "Identifier shown in show flow-sampler" <field-definition> suffix
"FLOW_SAMPLER_MODE"               49    1    "The type of algorithm used for sampling data: 0x02 random sampling. Use in connection with FLOW_SAMPLER_MODE" <field-definition> suffix
"FLOW_SAMPLER_RANDOM_INTERVAL"    50    4    "Packet interval at which to sample. Use in connection with FLOW_SAMPLER_MODE" <field-definition> suffix
"Vendor_1"                        51    0    "" <field-definition> suffix
"MIN_TTL"                         52    1    "Minimum TTL on incoming packets of the flow" <field-definition> suffix
"MAX_TTL"                         53    1    "Maximum TTL on incoming packets of the flow" <field-definition> suffix
"IPV4_IDENT"                      54    2    "The IP v4 identification field" <field-definition> suffix
"DST_TOS"                         55    1    "Type of Service byte setting when exiting outgoing interface" <field-definition> suffix
"IN_SRC_MAC"                      56    6    "Incoming source MAC address" <field-definition> suffix
"OUT_DST_MAC"                     57    6    "Outgoing destination MAC address" <field-definition> suffix
"SRC_VLAN"                        58    2    "Virtual LAN identifier associated with ingress interface" <field-definition> suffix
"DST_VLAN"                        59    2    "Virtual LAN identifier associated with egress interface" <field-definition> suffix
"IP_PROTOCOL_VERSION"             60    1    "Internet Protocol Version Set to 4 for IPv4, set to 6 for IPv6. If not present in the template, then version 4 is assumed." <field-definition> suffix
"DIRECTION"                       61    1    "Flow direction: 0 - ingress flow, 1 - egress flow" <field-definition> suffix
"IPV6_NEXT_HOP"                   62    16   "IPv6 address of the next-hop router" <field-definition> suffix
"BPG_IPV6_NEXT_HOP"               63    16   "Next-hop router in the BGP domain" <field-definition> suffix
"IPV6_OPTION_HEADERS"             64    4    "Bit-encoded field identifying IPv6 option headers found in the flow" <field-definition> suffix
"Vendor_2"                        65    0    "" <field-definition> suffix
"Vendor_3"                        66    0    "" <field-definition> suffix
"Vendor_4"                        67    0    "" <field-definition> suffix
"Vendor_5"                        68    0    "" <field-definition> suffix
"Vendor_6"                        69    0    "" <field-definition> suffix
"MPLS_LABEL_1"                    70    3    "MPLS label at position 1 in the stack" <field-definition> suffix
"MPLS_LABEL_2"                    71    3    "MPLS label at position 2 in the stack" <field-definition> suffix
"MPLS_LABEL_3"                    72    3    "MPLS label at position 3 in the stack" <field-definition> suffix
"MPLS_LABEL_4"                    73    3    "MPLS label at position 4 in the stack" <field-definition> suffix
"MPLS_LABEL_5"                    74    3    "MPLS label at position 5 in the stack" <field-definition> suffix
"MPLS_LABEL_6"                    75    3    "MPLS label at position 6 in the stack" <field-definition> suffix
"MPLS_LABEL_7"                    76    3    "MPLS label at position 7 in the stack" <field-definition> suffix
"MPLS_LABEL_8"                    77    3    "MPLS label at position 8 in the stack" <field-definition> suffix
"MPLS_LABEL_9"                    78    3    "MPLS label at position 9 in the stack" <field-definition> suffix
"MPLS_LABEL_10"                   79    3    "MPLS label at position 10 in the stack" <field-definition> suffix
"IN_DST_MAC"                      80    6    "Incoming destination MAC address" <field-definition> suffix
"OUT_SRC_MAC"                     81    6    "Outgoing source MAC address" <field-definition> suffix
"IF_NAME"                         82    4    "Shortened interface name e.g. FE1/0"     <field-definition> suffix
"IF_DESC"                         83    4    "Full interface name e.g. FastEthernet 1/0"     <field-definition> suffix
"SAMPLER_NAME"                    84    4    "Name of the flow sampler" <field-definition> suffix
"IN_PERMANENT_BYTES"              85    4    "Running byte counter for a permanent flow" <field-definition> suffix
"IN_PERMANENT_PKTS"               86    4    "Running packet counter for a permanent flow" <field-definition> suffix
"Vendor_7"                        87    0    "" <field-definition> suffix
"FRAGMENT_OFFSET"                 88    2    "The fragment-offset value from fragmented IP packets" <field-definition> suffix
"FORWARDING STATUS"               89    1    "Forwarding status is encoded on 1 byte with the 2 left bits giving the status and the 6 remaining bits giving the reason code." <field-definition> suffix
"MPLS PAL RD"                     90    8    "(array) MPLS PAL Route Distinguisher." <field-definition> suffix
"MPLS PREFIX LEN"                 91    1    "Number of consecutive bits in the MPLS prefix length." <field-definition> suffix
"SRC TRAFFIC INDEX"               92    4    "BGP Policy Accounting Source Traffic Index" <field-definition> suffix
"DST TRAFFIC INDEX"               93    4    "BGP Policy Accounting Destination Traffic Index" <field-definition> suffix
"APPLICATION DESCRIPTION"         94    0    "Application description." <field-definition> suffix
"APPLICATION TAG"                 95    1    "8 bits of engine ID, followed by n bits of classification." <field-definition> suffix
"APPLICATION NAME"                96    0    "Name associated with a classification." <field-definition> suffix
"MISSING"                         97    1    "Mising in document" <field-definition> suffix
"postipDiffServCodePoint"         98    1    "The value of a Differentiated Services Code Point (DSCP) encoded in the Differentiated Services Field, after modification." <field-definition> suffix
"replication factor"              99    4    "Multicast replication factor." <field-definition> suffix
"DEPRECATED"                      100   0    "DEPRECATED" <field-definition> suffix
"layer2packetSectionOffset"       102   0    "Layer 2 packet section offset. Potentially a generic offset." <field-definition> suffix
"layer2packetSectionSize"         103   0    "Layer 2 packet section size. Potentially a generic size." <field-definition> suffix
"layer2packetSectionData"         104   0    "Layer 2 packet section data." <field-definition> suffix
field-definitions set

SYMBOL: flows

FROM: alien.c-types => short ;
BE-PACKED-STRUCT: nf-header
{ version ushort }
{ count ushort }
{ sysuptime uint }
{ timestamp uint }
{ flowsequence uint }
;

BE-PACKED-STRUCT: nf-template
{ flowsetid ushort }
{ length ushort }
{ templateid ushort }
{ fieldcount ushort }
;

BE-PACKED-STRUCT: nf-data
{ flowsetid ushort }
{ length ushort }
{ value ushort }
;

BE-PACKED-STRUCT: nf-field
{ type ushort }
{ length ushort }
;

SYMBOL: netflow-connection
SYMBOL: flow-source

: flowsocket ( -- )
    f 9997 <inet4> <datagram>
    flow-source set ;

: flowfile ( path -- )
    binary <file-reader>
    flow-source set ;

: flowsource ( -- source )
    flow-source get ;

: flowgram ( -- flowgram )
    flowsource
    [ 60 seconds swap set-timeout ] keep ;

: stop? ( -- ? )
    NSEvent -> modifierFlags  0 = not ;

: raw-flow ( byte-array -- seq )
   [ "%02x" sprintf ] { } map-as ;


: seq>number ( seq -- value )  0 [ 8 * shift + ] reduce-index ;

: firstflow ( -- )
  [ flowgram ]
  [ dup message>> [ errno>> ] dip
    "firstflow: errno: %d msg: %s\n" printf
    netflow-connection get dup
    [ dispose  flowgram ] when
  ] recover
  netflow-connection set
  netflow-connection get
  dup
  [ [ receive  drop ] with-timeout ]
  [ "firstflow: failed on second attempt, no flows\n" printf ]
  if
  flows set ;

: nextflow ( -- flow )
    netflow-connection get
    [ receive drop ] with-timeout ;

: get-struct ( byte-array struct -- byte-array <struct> )
    [ props>>  "struct-size" swap at  detach-nth ] keep
    memory>struct ;

: collect ( -- )
    firstflow
    [ stop? ]
    [ flows get
      nextflow
      raw-flow 1array  append
      "Flow captured" print
      flows set ] until
      netflow-connection get dispose
      ;