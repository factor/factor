USING: io io.encodings io.encodings.iana kernel math ;

IN: io.encodings.latin1

SINGLETON: latin1

M: latin1 encode-char
    drop over 256 < [ stream-write1 ] [ encode-error ] if ;

M: latin1 decode-char
    drop stream-read1 [
        dup 256 < [ drop replacement-char ] unless
    ] [ f ] if* ;

latin1 "ISO_8859-1:1987" register-encoding
