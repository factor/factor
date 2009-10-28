! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences io.files io.files.temp io.launcher
io.pathnames io.encodings.ascii io.streams.string http.client
generalizations combinators math.parser math.vectors
math.intervals interval-maps memoize csv accessors assocs
strings math splitting grouping arrays combinators.smart ;
IN: geo-ip

: db-path ( -- path ) "IpToCountry.csv" temp-file ;

CONSTANT: db-url "http://software77.net/cgi-bin/ip-country/geo-ip.pl?action=download"

: download-db ( -- path )
    db-path dup exists? [
        db-url over ".gz" append download-to
        { "gunzip" } over ".gz" append absolute-path suffix try-process
    ] unless ;

TUPLE: ip-entry from to registry assigned city cntry country ;

: parse-ip-entry ( row -- ip-entry )
    [
        {
            [ string>number ]
            [ string>number ]
            [ ]
            [ ]
            [ ]
            [ ]
            [ ]
        } spread
    ] input<sequence ip-entry boa ;

MEMO: ip-db ( -- seq )
    download-db ascii file-lines
    [ "#" head? not ] filter "\n" join <string-reader> csv
    [ parse-ip-entry ] map ;

: filter-overlaps ( alist -- alist' )
    2 clump
    [ first2 [ first second ] [ first first ] bi* < ] filter
    [ first ] map ;

MEMO: ip-intervals ( -- interval-map )
    ip-db [ [ [ from>> ] [ to>> ] bi 2array ] keep ] { } map>assoc
    filter-overlaps <interval-map> ;

GENERIC: lookup-ip ( ip -- ip-entry )

M: string lookup-ip
    "." split [ string>number ] map
    { HEX: 1000000 HEX: 10000 HEX: 100 HEX: 1 } v.
    lookup-ip ;

M: integer lookup-ip ip-intervals interval-at ;
