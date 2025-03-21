! Copyright (C) 2025 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: arrays assocs calendar formatting http http.client
http.download io io.directories io.encodings.string
io.encodings.utf8 io.files.temp ip-parser json kernel
linked-assocs math.order math.parser namespaces present random
sequences splitting strings urls ;

IN: rdap

SYMBOL: rdap-url

: with-rdap ( url quot -- )
    rdap-url swap with-variable ; inline

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

: parse-services ( data quot: ( key -- key' ) -- services )
    [ "services" of ] dip '[ [ _ map ] dip ] assoc-map ; inline

: parse-range ( key -- {a,b} )
    "-" split1 over or [ string>number ] bi@ 2array ;

: asn-bootstrap ( -- services )
    "asn" bootstrap-get [ parse-range ] parse-services ;

: dns-bootstrap ( -- services )
    "dns" bootstrap-get "services" of ;

: ipv4-bootstrap ( -- services )
    "ipv4" bootstrap-get [ >ipv4-network ] parse-services ;

: ipv6-bootstrap ( -- services )
    "ipv6" bootstrap-get [ >ipv6-network ] parse-services ;

: object-bootstrap ( -- services )
    "object-tags" bootstrap-get "services" of [ rest ] map ;

: search-services ( services quot: ( key -- ? ) -- urls )
    '[ drop _ any? ] assoc-find drop nip ; inline

: asn-endpoints ( asn -- urls )
    asn-bootstrap [ first2 between? ] with search-services ;

: split-domain ( domain -- domains )
    "." split dup length <iota> [ tail "." join ] with map ;

: domain-endpoints ( domain -- urls )
    split-domain dns-bootstrap [ swap member? ] with search-services ;

: ipv4-endpoints ( ipv4 -- urls )
    ipv4-aton ipv4-bootstrap [ ipv4-contains? ] with search-services ;

: ipv6-endpoints ( ipv4 -- urls )
    ipv6-aton ipv6-bootstrap [ ipv6-contains? ] with search-services ;

CONSTANT: rir-endpoints H{
    { { "AFNIC" } "https://rdap.nic.fr/" }
    { { "AFRINIC" } "https://rdap.afrinic.net/rdap/" }
    { { "ARIN" } "https://rdap.arin.net/registry/" }
    { { "AP" } "https://rdap.apnic.net/" }
    { { "JP" } "https://jpnic.rdap.apnic.net/" }
    { { "ID" } "https://idnic.rdap.apnic.net/" }
    { { "KR" } "https://krnic.rdap.apnic.net/" }
    { { "LACNIC" } "https://rdap.lacnic.net/rdap/" }
    { { "BR" } "https://rdap.registro.br/" }
    { { "RIPE" } "https://rdap.db.ripe.net/" }
    { { "TW" } "https://twnic.rdap.apnic.net/" }
}

: entity-endpoint ( entity -- url )
    rir-endpoints [ [ head? ] [ tail? ] bi-curry bi or ] with search-services ;

: accept-rdap ( request -- request )
    "application/rdap+json" "Accept" set-header ;

: rdap-get ( url -- response rdap )
    <get-request> accept-rdap http-request
    dup string? [ utf8 decode ] unless json> ;

: rdap-lookup ( param endpoint-quot path-quot -- results )
    [ '[ rdap-url get [ nip ] _ if* ] ] dip '[ @ derive-url rdap-get nip ] bi ; inline

PRIVATE>

: lookup-asn ( asn -- results )
    dup string? [ "AS" ?head drop string>number ] when
    [ asn-endpoints random ] [ "autnum/%d" sprintf ] rdap-lookup ;

: lookup-domain ( domain -- results )
    [ domain-endpoints random ] [ "domain/%s" sprintf ] rdap-lookup ;

: lookup-ipv4 ( ipv4 -- results )
    [ ipv4-endpoints random ] [ "ip/%s" sprintf ] rdap-lookup ;

: lookup-ipv6 ( ipv6 -- results )
    [ ipv6-endpoints random ] [ "ip/%s" sprintf ] rdap-lookup ;

: lookup-entity ( entity -- results )
    [ entity-endpoint ] [ "entity/%s" sprintf ] rdap-lookup ;

: lookup-nameserver ( nameserver -- results )
    [ domain-endpoints random ] [ "nameserver/%s" sprintf ] rdap-lookup ;

<PRIVATE

GENERIC: print-rdap-nested ( padding key value -- )

M: linked-assoc print-rdap-nested
    [ over write write ":" print "  " append ] dip
    [ swapd print-rdap-nested ] with assoc-each ;

M: array print-rdap-nested
    [ print-rdap-nested ] 2with each ;

M: object print-rdap-nested
    present [ 2drop ] [ [ ": " [ write ] tri@ ] dip print ] if-empty ;

PRIVATE>

: print-rdap ( results -- )
    [ "" -rot print-rdap-nested ] assoc-each ;

<PRIVATE

: rdap-search-url ( -- url )
    rdap-url get [ "https://root.rdap.org/" ] unless* ;

: rdap-search ( pattern path key -- results )
    swapd [ rdap-search-url ] 3dip [ derive-url ] 2dip
    set-query-param rdap-get nip ;

PRIVATE>

: search-domains-by-name ( pattern -- results )
    "domains" "name" rdap-search ;

: search-domains-by-nameserver ( pattern -- results )
    "domains" "nsLdhName" rdap-search ;

: search-domains-by-nameserver-ip ( ip -- results )
    "domains" "nsIp" rdap-search ;

: search-nameservers-by-name ( pattern -- results )
    "nameservers" "name" rdap-search ;

: search-nameservers-by-ip ( ip -- results )
    "nameservers" "ip" rdap-search ;

: search-entities-by-name ( pattern -- results )
    "entities" "fn" rdap-search ;

: search-entities-by-handle ( pattern -- results )
    "entities" "handle" rdap-search ;
