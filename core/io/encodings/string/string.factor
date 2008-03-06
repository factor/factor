USING: io io.streams.byte-array ;
IN: io.encodings.string

: decode ( byte-array encoding -- string )
    <byte-reader> contents ;

: encode ( string encoding -- byte-array )
    [ write ] with-byte-writer ;
