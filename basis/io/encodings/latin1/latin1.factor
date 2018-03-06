USING: io io.encodings io.encodings.iana kernel math sequences ;

IN: io.encodings.latin1

SINGLETON: latin1

: latin1-encode ( char -- byte )
    dup 256 < [ encode-error ] unless ; inline

M: latin1 encode-char
    drop [ latin1-encode ] dip stream-write1 ;

M: latin1 encode-string
    drop [ [ latin1-encode ] B{ } map-as ] dip stream-write ;

M: latin1 decode-char
    drop stream-read1 [
        dup 256 < [ drop replacement-char ] unless
    ] [ f ] if* ;

latin1 "ISO_8859-1:1987" register-encoding
