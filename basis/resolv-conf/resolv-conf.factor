! Copyright (C) 2010 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors combinators io.encodings.utf8 io.files kernel
math math.parser sequences splitting unicode ;
IN: resolv-conf

TUPLE: network ip netmask ;
C: <network> network

TUPLE: options
debug?
edns0?
insecure1?
insecure2?
{ ndots integer initial: 1 }
{ timeout integer initial: 5 }
{ attempts integer initial: 2 }
rotate? no-check-names? inet6? tcp? ;

: <options> ( -- options ) options new ;

TUPLE: resolv.conf nameserver domain lookup search sortlist options ;

: <resolv.conf> ( -- resolv.conf )
    resolv.conf new
    V{ } clone >>nameserver
    V{ } clone >>domain
    V{ } clone >>search
    V{ } clone >>sortlist
    V{ } clone >>lookup
    <options> >>options ;

<PRIVATE

: trim-blanks ( string -- string' ) [ blank? ] trim ;

: split-line ( resolv.conf string -- resolv.conf seq resolv.conf )
    trim-blanks split-words
    [ trim-blanks ] map harvest over ;

: parse-nameserver ( resolv.conf string -- resolv.conf )
    split-line nameserver>> push-all ;

: parse-domain ( resolv.conf string -- resolv.conf )
    split-line domain>> push-all ;

: parse-lookup ( resolv.conf string -- resolv.conf )
    split-line lookup>> push-all ;

: parse-search ( resolv.conf string -- resolv.conf )
    split-line search>> push-all ;

: parse-sortlist ( resolv.conf string -- resolv.conf )
    trim-blanks split-words
    [ trim-blanks "/" split1 <network> ] map >>sortlist ;

ERROR: unsupported-resolv.conf-option string ;

: parse-integer ( string -- n )
    trim-blanks ":" ?head drop trim-blanks string>number ;

: parse-options ( resolv.conf string -- resolv.conf )
    [ dup options>> ] dip trim-blanks split-words [ {
        { [ dup "debug" = ] [ drop t >>debug? ] }
        { [ "ndots" ?head ] [ parse-integer >>ndots ] }
        { [ "timeout" ?head ] [ parse-integer >>timeout ] }
        { [ "attempts" ?head ] [ parse-integer >>attempts ] }
        { [ dup "rotate" = ] [ drop t >>rotate? ] }
        { [ dup "no-check-names" = ] [ drop t >>no-check-names? ] }
        { [ dup "inet6" = ] [ drop t >>inet6? ] }
        { [ dup "ip6-bytestring" = ] [ drop ] }
        { [ dup "ip6-dotint" = ] [ drop ] }
        { [ dup "no-ip6-dotint" = ] [ drop ] }
        { [ dup "edns0" = ] [ drop t >>edns0? ] }
        { [ dup "single-request" = ] [ drop ] }
        { [ dup "single-request-reopen" = ] [ drop ] }
        { [ dup "no-tld-query" = ] [ drop ] }
        { [ dup "use-vc" = ] [ drop ] }
        { [ dup "no-reload" = ] [ drop ] }
        { [ dup "trust-ad" = ] [ drop ] }
        [ unsupported-resolv.conf-option ]
    } cond drop ] with each ;

ERROR: unsupported-resolv.conf-line string ;

: parse-resolv.conf-line ( resolv.conf string -- resolv.conf )
    {
        { [ "nameserver" ?head ] [ parse-nameserver ] }
        { [ "domain" ?head ] [ parse-domain ] }
        { [ "lookup" ?head ] [ parse-lookup ] }
        { [ "search" ?head ] [ parse-search ] }
        { [ "sortlist" ?head ] [ parse-sortlist ] }
        { [ "options" ?head ] [ parse-options ] }
        [ unsupported-resolv.conf-line ]
    } cond ;

PRIVATE>

: lines>resolv.conf ( lines -- resolv.conf )
    [ <resolv.conf> ] dip
    [ [ blank? ] trim ] map harvest
    [ "#" head? ] reject
    [ parse-resolv.conf-line ] each ;

: string>resolv.conf ( string -- resolv.conf )
    split-lines lines>resolv.conf ;

: path>resolv.conf ( path -- resolv.conf )
    utf8 file-lines lines>resolv.conf ;

: default-resolv.conf ( -- resolv.conf )
    "/etc/resolv.conf" path>resolv.conf ;
