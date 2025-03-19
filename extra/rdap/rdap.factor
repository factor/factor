! Copyright (C) 2025 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: arrays assocs calendar combinators formatting http
http.client http.download io io.directories io.encodings.string
io.encodings.utf8 io.files.temp io.pathnames ip-parser json
kernel linked-assocs make math math.bitwise math.order
math.parser namespaces present random ranges sequences splitting
strings urls ;

IN: rdap

INITIALIZED-SYMBOL: bootstrap-cache [ 30 days ]

CONSTANT: bootstrap-files { "asn" "dns" "ipv4" "ipv6" "object-tags" }

: reset-bootstrap ( -- )
    [ bootstrap-files [ ".json" append ?delete-file ] each ] with-cache-directory ;

<PRIVATE

: bootstrap-url ( type -- url )
    "https://data.iana.org/rdap/" ".json" surround ;

: bootstrap-get ( type -- data )
    bootstrap-url cache-directory bootstrap-cache get
    download-outdated-into path>json ;

: parse-services ( data -- services )
    [ "services" of [ swap [ ,, ] with each ] assoc-each ] LH{ } make ;

: asn-bootstrap ( -- services )
    "asn" bootstrap-get parse-services [
        [ "-" split1 over or [ string>number ] bi@ 2array ] dip
    ] assoc-map ;

: dns-bootstrap ( -- services )
    "dns" bootstrap-get parse-services ;

: ipv4-bootstrap ( -- services )
    "ipv4" bootstrap-get parse-services [
        [ "/" split1 [ ipv4-aton ] [ string>number ] bi* 2array ] dip
    ] assoc-map ;

: ipv6-bootstrap ( -- services )
    "ipv6" bootstrap-get parse-services [
        [ "/" split1 [ ipv6-aton ] [ string>number ] bi* 2array ] dip
    ] assoc-map ;

: object-bootstrap ( -- services )
    "object-tags" bootstrap-get "services" of ;

: asn-endpoints ( asn -- urls )
    asn-bootstrap >alist [ first first2 between? ] with find nip
    dup [ second ] when ;

: split-domain ( domain -- domains )
    "." split dup length <iota> [ tail "." join ] with map ;

: domain-endpoints ( domain -- urls )
    split-domain [ dns-bootstrap at ] map-find drop ;

: ipv4-endpoints ( ipv4 -- urls )
    ipv4-aton ipv4-bootstrap >alist [
        first first2 [ on-bits ] [ 32 swap - shift ] bi swapd mask =
    ] with find nip dup [ second ] when ;

: ipv6-endpoints ( ipv4 -- urls )
    ipv6-aton ipv6-bootstrap >alist [
        first first2 [ on-bits ] [ 128 swap - shift ] bi swapd mask =
    ] with find nip dup [ second ] when ;

CONSTANT: rdap-fallbacks {
    "https://rdap.arin.net/registry/"
    "https://rdap.db.ripe.net/"
    "https://rdap.apnic.net/"
}

CONSTANT: rir-endpoints H{
    { "afnic" "https://rdap.nic.fr/" }
    { "afrinic" "https://rdap.afrinic.net/rdap/" }
    { "arin" "https://rdap.arin.net/registry/" }
    { "apnic" "https://rdap.apnic.net/" }
    { "jpnic" "https://jpnic.rdap.apnic.net/" }
    { "idnic" "https://idnic.rdap.apnic.net/" }
    { "krnic" "https://krnic.rdap.apnic.net/" }
    { "lacnic" "https://rdap.lacnic.net/rdap/" }
    { "registro.br" "https://rdap.registro.br/" }
    { "ripe" "https://rdap.db.ripe.net/" }
    { "twnic" "https://twnic.rdap.apnic.net/" }
}

CONSTANT: rir-entity-prefixes H{
    { "AFNIC" "afnic" }
    { "AFRINIC" "afrinic" }
    { "ARIN" "arin" }
    { "AP" "apnic" }
    { "JPNIC" "jpnic" }
    { "KR" "krnic" }
    { "ID" "idnic" }
    { "LACNIC" "lacnic" }
    { "BR" "registro.br" } ! registro.br currently does not use entity prefixes
    { "RIPE" "ripe" }
    { "TW" "twnic" }

}

: entity-endpoint ( entity -- url )
    rir-entity-prefixes >alist [
        first [ head? ] [ tail? ] bi-curry bi or
    ] with find nip dup [ second ] when rir-endpoints at ;

: accept-rdap ( request -- request )
    "application/rdap+json" "Accept" set-header ;

: rdap-get ( url -- response rdap )
    <get-request> accept-rdap http-request
    dup string? [ utf8 decode ] unless json> ;

PRIVATE>

: lookup-asn ( asn -- results )
    dup string? [ "AS" ?head drop string>number ] when
    [ asn-endpoints random ] [ "autnum/%d" sprintf derive-url rdap-get nip ] bi ;

: lookup-domain ( domain -- results )
    [ domain-endpoints random ] [ "domain/%s" sprintf derive-url rdap-get nip ] bi ;

: lookup-ipv4 ( ipv4 -- results )
    [ ipv4-endpoints random ] [ "ip/%s" sprintf derive-url rdap-get nip ] bi ;

: lookup-ipv6 ( ipv6 -- results )
    [ ipv6-endpoints random ] [ "ip/%s" sprintf derive-url rdap-get nip ] bi ;

: lookup-entity ( entity -- results )
    [ entity-endpoint ] [ "entity/%s" sprintf derive-url rdap-get nip ] bi ;

<PRIVATE

GENERIC: print-rdap-nested ( padding key value -- )

M: linked-assoc print-rdap-nested
    [ over write write ":" print ] dip [
        [ dup "  " append ] 2dip print-rdap-nested
    ] assoc-each drop ;

M: array print-rdap-nested
    [ print-rdap-nested ] 2with each ;

M: object print-rdap-nested
    present [ 2drop ] [
        [ [ write ] bi@ ": " write ] dip print
    ] if-empty ;

PRIVATE>

: print-rdap ( results -- )
    [ "" -rot print-rdap-nested ] assoc-each ;
