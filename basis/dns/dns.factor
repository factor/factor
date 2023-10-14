! Copyright (C) 2010 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.enums alien.syntax arrays ascii calendar
combinators combinators.smart constructors continuations endian
grouping io io.encodings.binary io.encodings.string
io.encodings.utf8 io.sockets io.sockets.private
io.streams.byte-array io.timeouts kernel make math math.bitwise
math.parser namespaces random sequences slots.syntax splitting
system vectors vocabs ;
FROM: io.encodings.ascii => ascii ;
IN: dns

: with-input-seek ( n seek-type quot -- )
    tell-input [
        [ seek-input ] dip call
    ] dip seek-absolute seek-input ; inline

! https://www.iana.org/assignments/dns-parameters/dns-parameters.xhtml
ENUM: dns-type
{ A 1 } { NS 2 } { MD 3 } { MF 4 }
{ CNAME 5 } { SOA 6 } { MB 7 } { MG 8 }
{ MR 9 } { NULL 10 } { WKS 11 } { PTR 12 }
{ HINFO 13 } { MINFO 14 } { MX 15 } { TXT 16 }
{ RP 17 } { AFSDB 18 } { X25 19 } { ISDN 20 } { RT 21 }
{ NSAP 22 } { NSAP-PTR 23 } { SIG 24 } { KEY 25 } { PX 26 }
{ GPOS 27 } { AAAA 28 } { LOC 29 } { NXT 30 } { EID 31 }
{ NIMLOC 32 } { SRV 33 } { ATMA 34 } { NAPTR 35 } { KX 36 }
{ CERT 37 } { A6 38 } { DNAME 39 } { SINK 40 } { OPT 41 }
{ APL 42 } { DS 43 } { SSHFP 44 } { IPSECKEY 45 }
{ RRSIG 46 } { NSEC 47 } { DNSKEY 48 } { DHCID 49 }
{ NSEC3 50 } { NSEC3PARAM 51 } { TLSA 52 } { SMIMEA 53 }
{ HIP 55 } { NINFO 56 } { RKEY 57 } { TALINK 58 }
{ CDS 59 } { CDNSKEY 60 } { OPENPGPKEY 61 }
{ CSYNC 62 } { ZONEMD 63 } { SVCB 64 } { HTTPS 65 }
{ SPF 99 } { UINFO 100 } { UID 101 } { GID 102 } { UNSPEC 103 }
{ NID 104 } { L32 105 } { L64 106 } { LP 107 } { EUI48 108 } { EUI64 109 }
{ TKEY 249 } { TSIG 250 } { IXFR 251 } { AXFR 252 } { MAILB 253 } { MAILA 254 }
{ DNS* 255 } { URI 256 } { CAA 257 } { AVC 258 } { DOA 259 } { AMTRELAY 260 }
{ TA 32768 } { DLV 32769 } ;

ENUM: dns-class { IN 1 } { CS 2 } { CH 3 } { HS 4 } ;

ENUM: dns-opcode QUERY IQUERY STATUS ;

ENUM: dns-rcode NO-ERROR FORMAT-ERROR SERVER-FAILURE
NAME-ERROR NOT-IMPLEMENTED REFUSED ;

SYMBOL: dns-servers

: add-dns-server ( string -- )
    dns-servers get push ;

: remove-dns-server ( string -- )
    dns-servers get remove! drop ;

: clear-dns-servers ( -- )
    V{ } clone dns-servers set-global ;

ERROR: domain-name-contains-empty-label domain ;

: check-domain-name ( domain -- domain )
    dup ".." subseq-of? [ domain-name-contains-empty-label ] when ;

: >dotted ( domain -- domain' )
    dup "." tail? [ "." append ] unless ;

: dotted> ( string -- string' )
    "." ?tail drop ;

TUPLE: query name type class ;
CONSTRUCTOR: <query> query ( name type class -- obj )
    [ check-domain-name >dotted ] change-name ;

TUPLE: rr name type class ttl rdata ;

TUPLE: hinfo cpu os ;

TUPLE: mx preference exchange ;

TUPLE: soa mname rname serial refresh retry expire minimum ;

TUPLE: srv priority weight port target ;

TUPLE: a name ;
CONSTRUCTOR: <a> a ( name -- obj ) ;

TUPLE: aaaa name ;
CONSTRUCTOR: <aaaa> aaaa ( name -- obj ) ;

TUPLE: cname name ;
CONSTRUCTOR: <cname> cname ( name -- obj ) ;

TUPLE: ptr name ;
CONSTRUCTOR: <ptr> ptr ( name -- obj ) ;

TUPLE: ns name ;
CONSTRUCTOR: <ns> ns ( name -- obj ) ;

TUPLE: message id qr opcode aa tc rd ra z rcode
query answer-section authority-section additional-section ;

CONSTRUCTOR: <message> message ( query -- obj )
    16 2^ random >>id
    0 >>qr
    QUERY >>opcode
    0 >>aa
    0 >>tc
    1 >>rd
    0 >>ra
    0 >>z
    NO-ERROR >>rcode
    [ dup sequence? [ 1array ] unless ] change-query
    { } >>answer-section
    { } >>authority-section
    { } >>additional-section ;

: message>header ( message -- n )
    [
        {
            [ qr>> 15 shift ]
            [ opcode>> enum>number 11 shift ]
            [ aa>> 10 shift ]
            [ tc>> 9 shift ]
            [ rd>> 8 shift ]
            [ ra>> 7 shift ]
            [ z>> 4 shift ]
            [ rcode>> enum>number 0 shift ]
        } cleave
    ] sum-outputs ;

: header>message-parts ( n -- qr opcode aa tc rd ra z rcode )
    {
        [ -15 shift 0b1 bitand ]
        [ -11 shift 0b111 bitand <dns-opcode> ]
        [ -10 shift 0b1 bitand ]
        [ -9 shift 0b1 bitand ]
        [ -8 shift 0b1 bitand ]
        [ -7 shift 0b1 bitand ]
        [ -4 shift 0b111 bitand ]
        [ 0b1111 bitand <dns-rcode> ]
    } cleave ;

: byte-array>ipv4 ( byte-array -- string )
    [ number>string ] { } map-as "." join ;

: byte-array>ipv6 ( byte-array -- string )
    2 group [ be> >hex ] { } map-as ":" join ;

: ipv4>byte-array ( string -- byte-array )
    "." split [ string>number ] B{ } map-as ;

: ipv6>byte-array ( string -- byte-array )
    T{ inet6 } inet-pton ;

: expand-ipv6 ( ipv6 -- ipv6' ) ipv6>byte-array byte-array>ipv6 ;

: reverse-ipv4 ( string -- string )
    ipv4>byte-array reverse byte-array>ipv4 ;

CONSTANT: ipv4-arpa-suffix ".in-addr.arpa"

: ipv4>arpa ( string -- string )
    reverse-ipv4 ipv4-arpa-suffix append ;

CONSTANT: ipv6-arpa-suffix ".ip6.arpa"

: ipv6>arpa ( string -- string )
    ipv6>byte-array
    [ [ -4 shift 4 bits ] [ 4 bits ] bi 2array ] { } map-as
    B{ } concat-as reverse
    [ >hex ] { } map-as "." join ipv6-arpa-suffix append ;

: trim-ipv4-arpa ( string -- string' )
    dotted> ipv4-arpa-suffix ?tail drop ;

: trim-ipv6-arpa ( string -- string' )
    dotted> ipv6-arpa-suffix ?tail drop ;

: arpa>ipv4 ( string -- ip ) trim-ipv4-arpa reverse-ipv4 ;

: arpa>ipv6 ( string -- ip )
    trim-ipv6-arpa "." split 2 group reverse
    [
        first2 swap [ hex> ] bi@ [ 4 shift ] [ ] bi* bitor
    ] B{ } map-as byte-array>ipv6 ;

: parse-length-bytes ( byte -- sequence ) read utf8 decode ;

: (parse-name) ( -- )
    read1 [
        dup 0xC0 mask? [
            8 shift read1 bitor 0x3fff bitand
            seek-absolute [
                read1 parse-length-bytes , (parse-name)
            ] with-input-seek
        ] [
            parse-length-bytes , (parse-name)
        ] if
    ] unless-zero ;

: parse-name ( -- sequence )
    [ (parse-name) ] { } make "." join ;

: parse-query ( -- query )
    parse-name
    2 read be> <dns-type>
    2 read be> <dns-class> <query> ;

: parse-soa ( -- soa )
    soa new
        parse-name >>mname
        parse-name >>rname
        4 read be> >>serial
        4 read be> >>refresh
        4 read be> >>retry
        4 read be> >>expire
        4 read be> >>minimum ;

: parse-mx ( -- mx )
    mx new
        2 read be> >>preference
        parse-name >>exchange ;

: parse-srv ( -- srv )
    srv new
    2 read be> >>priority
    2 read be> >>weight
    2 read be> >>port
    parse-name >>target ;

ERROR: invalid-hinfo-record length ;

: (parse-hinfo-piece) ( -- s )
    read1 dup 40 <
    [ read ascii decode ] [ invalid-hinfo-record throw ] if ;

: parse-hinfo ( -- hinfo )
    (parse-hinfo-piece) (parse-hinfo-piece) hinfo boa ;

GENERIC: parse-rdata ( n type -- obj )

M: object parse-rdata drop read ;
M: A parse-rdata 2drop 4 read byte-array>ipv4 <a> ;
M: AAAA parse-rdata 2drop 16 read byte-array>ipv6 <aaaa> ;
M: CNAME parse-rdata 2drop parse-name <cname> ;
M: HINFO parse-rdata 2drop parse-hinfo ;
M: MX parse-rdata 2drop parse-mx ;
M: NS parse-rdata 2drop parse-name <ns> ;
M: PTR parse-rdata 2drop parse-name <ptr> ;
M: SOA parse-rdata 2drop parse-soa ;
M: SRV parse-rdata 2drop parse-srv ;

: parse-rr ( -- rr )
    rr new
        parse-name >>name
        2 read be> <dns-type> >>type
        2 read be> <dns-class> >>class
        4 read be> >>ttl
        2 read be> over type>> parse-rdata >>rdata ;

: parse-message ( byte-array -- message )
    [ message new ] dip
    binary [
        2 read be> >>id
        2 read be> header>message-parts set-slots[ qr opcode aa tc rd ra z rcode ]
        2 read be> >>query
        2 read be> >>answer-section
        2 read be> >>authority-section
        2 read be> >>additional-section
        [ [ parse-query ] replicate ] change-query
        [ [ parse-rr ] replicate ] change-answer-section
        [ [ parse-rr ] replicate ] change-authority-section
        [ [ parse-rr ] replicate ] change-additional-section
    ] with-byte-reader ;

ERROR: unsupported-domain-name string ;

: >n/label ( string -- byte-array )
    dup [ ascii? ] all?
    [ unsupported-domain-name ] unless
    [ length 1array ] [ ] bi B{ } append-as ;

: >name ( domain -- byte-array )
    dup "." = [ drop B{ 0 } ] [
        "." split [ >n/label ] map concat
    ] if ;

: query>byte-array ( query -- byte-array )
    [
        {
            [ name>> >name ]
            [ type>> enum>number 2 >be ]
            [ class>> enum>number 2 >be ]
        } cleave
    ] B{ } append-outputs-as ;

GENERIC: rdata>byte-array ( rdata type -- obj )

M: A rdata>byte-array drop ipv4>byte-array ;

M: CNAME rdata>byte-array drop >name ;

M: HINFO rdata>byte-array
    drop
    [ cpu>> >name ]
    [ os>> >name ] bi append ;

M: MX rdata>byte-array
    drop
    [ preference>> 2 >be ]
    [ exchange>> >name ] bi append ;

M: NS rdata>byte-array drop >name ;

M: PTR rdata>byte-array drop >name ;

M: SOA rdata>byte-array
    drop
    [
        {
            [ mname>> >name ]
            [ rname>> >name ]
            [ serial>> 4 >be ]
            [ refresh>> 4 >be ]
            [ retry>> 4 >be ]
            [ expire>> 4 >be ]
            [ minimum>> 4 >be ]
        } cleave
    ] B{ } append-outputs-as ;

M: TXT rdata>byte-array
    drop ;

: rr>byte-array ( rr -- byte-array )
    [
        {
            [ name>> >name ]
            [ type>> enum>number 2 >be ]
            [ class>> enum>number 2 >be ]
            [ ttl>> 4 >be ]
            [
                [ rdata>> ] [ type>> ] bi rdata>byte-array
                [ length 2 >be ] [ ] bi append
            ]
        } cleave
    ] B{ } append-outputs-as ;

: message>byte-array ( message -- byte-array )
    [
        {
            [ id>> 2 >be ]
            [ message>header 2 >be ]
            [ query>> length 2 >be ]
            [ answer-section>> length 2 >be ]
            [ authority-section>> length 2 >be ]
            [ additional-section>> length 2 >be ]
            [ query>> [ query>byte-array ] map concat ]
            [ answer-section>> [ rr>byte-array ] map concat ]
            [ authority-section>> [ rr>byte-array ] map concat ]
            [ additional-section>> [ rr>byte-array ] map concat ]
        } cleave
    ] B{ } append-outputs-as ;

: udp-query ( bytes server -- bytes' )
    [
        10 seconds over set-timeout
        [ send ] [ receive drop ] bi
    ] with-any-port-local-datagram ;

: parse-ip ( str -- ipv4/ipv6 )
    [ <ipv4> ] [ drop <ipv6> ] recover ;

: <dns-inet> ( -- inet4 )
    dns-servers get
    [ parse-ip ] map [ ipv4? ] filter
    random host>> 53 <inet4> ;

: dns-query ( name type class -- message )
    <query> <message> message>byte-array
    <dns-inet> udp-query parse-message ;

: dns-A-query ( name -- message ) A IN dns-query ;
: dns-AAAA-query ( name -- message ) AAAA IN dns-query ;
: dns-CNAME-query ( name -- message ) CNAME IN dns-query ;
: dns-LOC-query ( name -- message ) LOC IN dns-query ;
: dns-HINFO-query ( name -- message ) HINFO IN dns-query ;
: dns-MX-query ( name -- message ) MX IN dns-query ;
: dns-NS-query ( name -- message ) NS IN dns-query ;
: dns-TXT-query ( name -- message ) TXT IN dns-query ;
: dns-SRV-query ( name -- message ) SRV IN dns-query ;

: read-TXT-strings ( byte-array -- strings )
    [
        binary <byte-reader> [
            [ read1 [ read , t ] [ f ] if* ] loop
        ] with-input-stream
    ] { } make ;

: TXT-message>strings ( message -- strings )
    answer-section>>
    [ rdata>>
        read-TXT-strings [ utf8 decode ] map
    ] map ;

: TXT. ( name -- )
    dns-TXT-query TXT-message>strings [ [ write ] each nl ] each ;

: reverse-lookup ( reversed-ip -- message )
    PTR IN dns-query ;

: reverse-ipv4-lookup ( ip -- message )
    ipv4>arpa reverse-lookup ;

: reverse-ipv6-lookup ( ip -- message )
    ipv6>arpa reverse-lookup ;

: message>names ( message -- names )
    answer-section>> [ rdata>> name>> ] map ;

: filter-message-rdata>names ( message quot -- names )
    [ answer-section>> [ rdata>> ] map ] dip filter [ name>> ] map ; inline

: message>a-names ( message -- names )
    [ a? ] filter-message-rdata>names ;

: message>aaaa-names ( message -- names )
    [ aaaa? ] filter-message-rdata>names ;

: message>mxs ( message -- assoc )
    answer-section>> [
        rdata>> dup cname? [
            name>> 1array
        ] [
            [ preference>> ] [ exchange>> ] bi 2array
        ] if
    ] map ;

: messages>names ( messages -- names )
    [ message>names ] map concat ;

: forward-confirmed-reverse-dns-ipv4? ( ipv4-string -- ? )
    dup reverse-ipv4-lookup message>names
    [ dns-A-query ] map messages>names member? ;

: forward-confirmed-reverse-dns-ipv6? ( ipv6-string -- ? )
    expand-ipv6
    dup reverse-ipv6-lookup message>names
    [ dns-AAAA-query ] map messages>names member? ;

: message>query-name ( message -- string )
    query>> first name>> dotted> ;

! XXX: Turn on someday for nonblocking DNS lookups
! M: string resolve-host
    ! dup >lower "localhost" = [
        ! drop resolve-localhost
    ! ] [
        ! dns-A-query message>a-names [ <ipv4> ] map
    ! ] if ;

HOOK: initial-dns-servers os ( -- sequence )

{
    { [ os windows? ] [ "dns.windows" ] }
    { [ os unix? ] [ "dns.unix" ] }
} cond require

: with-dns-servers ( servers quot -- )
    [ dns-servers ] dip with-variable ; inline

dns-servers [ initial-dns-servers >vector ] initialize
