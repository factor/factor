! Copyright (C) 2007 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.syntax byte-arrays io
io.sockets kernel structs math math.parser
prettyprint sequences ;
IN: io.sockets.headers

C-STRUCT: etherneth
    { { "char" 6 } "dmac" }
    { { "char" 6 } "smac" }
    { "ushort" "type" } ;

: >mac-address ( byte-array -- string )
    6 memory>byte-array
    [ >hex 2 48 pad-left ] { } map-as ":" join ;

: etherneth. ( etherneth -- )
    [ etherneth-dmac "Dest   MAC: " write >mac-address . ] keep
    [ etherneth-smac "Source MAC: " write >mac-address . ] keep
    [ etherneth-type "Type      : " write .h ] keep
    drop ;

C-STRUCT: iph
    { "uchar" "hl|v" } ! hl is 4 bits, v is 4 bits
    { "uchar" "tos" }
    { "short" "len" }
    { "short" "id" }
    { "short" "off" }
    { "uchar" "ttl" }
    { "uchar" "p" }
    { "ushort" "ip_sum" }
    { "uint" "ip_src" }
    { "uint" "ip_dst" } ;

: iph-hl ( iph -- n )
    iph-hl|v -4 shift ;

: iph-v ( iph -- n )
    iph-hl|v HEX: 0f bitand ;

: set-iph-hl ( n iph -- )
    [ iph-hl|v HEX: 0f bitand >r 4 shift r> bitor ] keep
    set-iph-hl|v ;

: set-iph-v ( n iph -- )
    [ iph-hl|v HEX: f0 bitand bitor ] keep
    set-iph-hl|v ;

C-STRUCT: icmph
    { "uchar" "type" }
    { "uchar" "code" }
    { "short" "chksum" }
    { "ushort" "id" }
    { "ushort" "seq" } ;

C-STRUCT: udph
    { "ushort" "sport" }
    { "ushort" "dport" }
    { "ushort" "len" }
    { "ushort" "check" } ;

C-STRUCT: tcph
    { "ushort" "sport" }
    { "ushort" "dport" }
    { "uint" "seq" }
    { "uint" "ack" }
    { "uchar" "x2|off" }
    { "uchar" "flags" }
    { "ushort" "win" }
    { "ushort" "sum" }
    { "ushort" "urp" } ;

: tcph-x2 ( iph -- n )
    tcph-x2|off -4 shift ;

: tcph-off ( iph -- n )
    tcph-x2|off HEX: 0f bitand ;

: set-tcph-x2 ( n iph -- )
    [ tcph-x2|off HEX: 0f bitand >r 4 shift r> bitor ] keep
    set-tcph-x2|off ;

: set-tcph-off ( n iph -- )
    [ tcph-x2|off HEX: 0f bitand bitor ] keep
    set-tcph-x2|off ;

