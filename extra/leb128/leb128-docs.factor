
USING: byte-arrays help.markup help.syntax ;

IN: leb128

ARTICLE: "leb128" "LEB128 Encoding"

LEB128 (Little Endian Base 128) is a variable-length encoding format designed
to store arbitrarily large integers in a small number of bytes. There are two
versions: unsigned and signed. These vary slightly, so a user program that
wants to decode LEB128 values should use the appropriate unsigned or signed
decode method.

Unsigned LEB128:
{ $subsections
    >uleb128
    uleb128>
    write-uleb128
    stream-write-uleb128
    read-uleb128
    stream-read-uleb128
}

Signed LEB128:
{ $subsections
    >leb128
    leb128>
    write-leb128
    stream-write-leb128
    read-leb128
    stream-read-leb128
} ;

ABOUT: "leb128"
