USING: alien.c-types hexdump io io.backend io.sockets.headers
io.sockets.headers.bsd kernel io.sniffer io.sniffer.bsd
io.streams.string io.unix.backend math
sequences system byte-arrays io.sniffer.filter.backend
io.sniffer.filter.backend io.sniffer.backend ;
IN: io.sniffer.filter.bsd

! http://www.iana.org/assignments/ethernet-numbers

: bpf-align ( n -- n' )
    ! Align to next higher word size
    "long" heap-size align ;

M: unix-io packet. ( string -- )
    18 cut swap >byte-array bpfh.
    (packet.) ;

M: unix-io sniffer-loop ( stream -- )
    nl nl
    4096 over stream-read-partial
        dup hexdump.
    packet.
    sniffer-loop ;


! Mac 
: sniff-wired ( -- )
    "/dev/bpf0" "en0" <sniffer-spec> <sniffer> sniffer-loop ;

! Macbook
: sniff-wireless ( -- )
    "/dev/bpf0" "en1" <sniffer-spec> <sniffer> sniffer-loop ;

