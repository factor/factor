USING: kernel sequences io.files io.launcher io.encodings.ascii
io.streams.string http.client sequences.lib combinators
math.parser math.vectors math.intervals interval-maps memoize
csv accessors assocs strings math splitting ;
IN: geo-ip

: db-path ( -- path ) "IpToCountry.csv" temp-file ;

: db-url ( -- url ) "http://software77.net/cgi-bin/ip-country/geo-ip.pl?action=download" ;

: download-db ( -- path )
    db-path dup exists? [
        db-url over ".gz" append download-to
        { "gunzip" } over ".gz" append (normalize-path) suffix try-process
    ] unless ;

TUPLE: ip-entry from to registry assigned city cntry country ;

: parse-ip-entry ( row -- ip-entry )
    7 firstn {
        [ string>number ]
        [ string>number ]
        [ ]
        [ ]
        [ ]
        [ ]
        [ ]
    } spread ip-entry boa ;

MEMO: ip-db ( -- seq )
    download-db ascii file-lines
    [ "#" head? not ] filter "\n" join <string-reader> csv
    [ parse-ip-entry ] map ;

MEMO: ip-intervals ( -- interval-map )
    ip-db [ [ [ from>> ] [ to>> ] bi [a,b] ] keep ] { } map>assoc
    <interval-map> ;

GENERIC: lookup-ip ( ip -- ip-entry )

M: string lookup-ip
    "." split [ string>number ] map
    { HEX: 1000000 HEX: 10000 HEX: 100 1 } v.
    lookup-ip ;

M: integer lookup-ip ip-intervals interval-at ;
