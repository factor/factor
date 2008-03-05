USING: io.encodings io io.streams.byte-array ;
IN: io.encodings.string

: decode-string ( byte-array encoding -- string )
    <byte-reader> contents ;
