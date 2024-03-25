! Copyright (C) 2008 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators combinators.smart csv
grouping http.client interval-maps io.encodings.ascii io.files
io.files.temp io.launcher io.pathnames ip-parser kernel math
math.parser sequences splitting strings ;
IN: geo-ip

: db-path ( -- path ) "IpToCountry.csv" cache-file ;

CONSTANT: db-url "https://software77.net/geo-ip/?DL=1"

: download-db ( -- path )
    db-path dup file-exists? [
        db-url over ".gz" append download-once-to
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
    [ "#" head? ] reject join-lines string>csv
    [ parse-ip-entry ] map ;

: filter-overlaps ( alist -- alist' )
    2 clump
    [ first2 [ first second ] [ first first ] bi* < ] filter
    keys ;

MEMO: ip-intervals ( -- interval-map )
    ip-db [ [ [ from>> ] [ to>> ] bi 2array ] keep ] { } map>assoc
    filter-overlaps <interval-map> ;

GENERIC: lookup-ip ( ip -- ip-entry )

M: string lookup-ip ipv4-aton lookup-ip ;

M: integer lookup-ip ip-intervals interval-at ;
