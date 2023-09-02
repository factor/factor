
USING: byte-arrays help.markup help.syntax ;

IN: leb128

ARTICLE: "leb128" "LEB128 Encoding"

Implements support for the LEB128 (Little Endian Base 128) encoding format,
both unsigned and signed.

Unsigned LEB123:
{ $subsections
    >uleb128
    uleb128>
    write-uleb128
    stream-write-uleb128
    read-uleb128
    stream-read-uleb128
}

Signed LEB123:
{ $subsections
    >leb128
    leb128>
    write-leb128
    stream-write-leb128
    read-leb128
    stream-read-leb128
} ;

ABOUT: "leb128"
