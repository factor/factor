! Copyright (C) 2010 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors combinators constructors io.encodings.utf8
io.files kernel math math.parser sequences splitting
unicode ;
IN: resolv-conf

TUPLE: network ip netmask ;
CONSTRUCTOR: <network> network ( ip netmask -- network ) ;

TUPLE: options
debug?
edns0?
insecure1?
insecure2?
{ ndots integer initial: 1 }
{ timeout integer initial: 5 }
{ attempts integer initial: 2 }
rotate? no-check-names? inet6? tcp? ;

CONSTRUCTOR: <options> options ( -- options ) ;

TUPLE: resolv.conf nameserver domain lookup search sortlist options ;

CONSTRUCTOR: <resolv.conf> resolv.conf ( -- resolv.conf )
    V{ } clone >>nameserver
    V{ } clone >>domain
    V{ } clone >>search
    V{ } clone >>sortlist
    V{ } clone >>lookup
    <options> >>options ;

<PRIVATE

: trim-blanks ( string -- string' ) [ blank? ] trim ;

: split-line ( resolv.conf string -- resolv.conf seq resolv.conf )
    trim-blanks " " split
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
    trim-blanks " " split
    [ trim-blanks "/" split1 <network> ] map >>sortlist ;

ERROR: unsupported-resolv.conf-option string ;

: parse-integer ( string -- n )
    trim-blanks ":" ?head drop trim-blanks string>number ;

: parse-option ( resolv.conf string -- resolv.conf )
    [ dup options>> ] dip trim-blanks {
        { [ "debug" ?head ] [ drop t >>debug? ] }
        { [ "ndots:" ?head ] [ parse-integer >>ndots ] }
        { [ "timeout" ?head ] [ parse-integer >>timeout ] }
        { [ "attempts" ?head ] [ parse-integer >>attempts ] }
        { [ "rotate" ?head ] [ drop t >>rotate? ] }
        { [ "no-check-names" ?head ] [ drop t >>no-check-names? ] }
        { [ "inet6" ?head ] [ drop t >>inet6? ] }
        [ unsupported-resolv.conf-option ]
    } cond drop ;

ERROR: unsupported-resolv.conf-line string ;

: parse-resolv.conf-line ( resolv.conf string -- resolv.conf )
    {
        { [ "nameserver" ?head ] [ parse-nameserver ] }
        { [ "domain" ?head ] [ parse-domain ] }
        { [ "lookup" ?head ] [ parse-lookup ] }
        { [ "search" ?head ] [ parse-search ] }
        { [ "sortlist" ?head ] [ parse-sortlist ] }
        { [ "options" ?head ] [ parse-option ] }
        [ unsupported-resolv.conf-line ]
    } cond ;

PRIVATE>

: parse-resolve.conf ( path -- resolv.conf )
    [ <resolv.conf> ] dip
    utf8 file-lines
    [ [ blank? ] trim ] map harvest
    [ "#" head? ] reject
    [ parse-resolv.conf-line ] each ;

: default-resolv.conf ( -- resolv.conf )
    "/etc/resolv.conf" parse-resolve.conf ;
