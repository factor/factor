! Copyright (C) 2007 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.syntax byte-arrays io
kernel math prettyprint ;
IN: io.sockets.headers.bsd

C-STRUCT: bpfh
    { "timeval" "timestamp" }
    { "ulong" "caplen" }
    { "ulong" "datalen" }
    { "ushort" "hdrlen" } ;

: bpfh. ( bpfh -- )
    [
        bpfh-timestamp "Timestamp: " write
        "timeval" heap-size memory>byte-array .
    ] keep
    [ bpfh-caplen "caplen: " write . ] keep
    [ bpfh-datalen "datalen: " write . ] keep
    [ bpfh-hdrlen "hdrlen: " write . ] keep
    drop ;

