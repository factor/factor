USING: help.markup help.syntax math io ;
IN: pack

HELP: packed-length
{ $values { "str" "a format string" } { "n" integer } }
{ $description "Computes the packed size, in bytes, of the structure described by the given format string (without actually packing or unpacking any data)." } ;

HELP: pack-native
{ $values { "seq" "a sequence of field values" } { "str" "a format string" } { "bytes" "a byte sequence" } }
{ $description "Packs the values in " { $snippet "seq" } " according to the field formats described by " { $snippet "str" } " into a byte sequence, using native byte order." } ;

HELP: pack-be
{ $values { "seq" "a sequence of field values" } { "str" "a format string" } { "bytes" "a byte sequence" } }
{ $description "Packs the values in " { $snippet "seq" } " according to the field formats described by " { $snippet "str" } " into a byte sequence, using big-endian byte order." } ;

HELP: pack-le
{ $values { "seq" "a sequence of field values" } { "str" "a format string" } { "bytes" "a byte sequence" } }
{ $description "Packs the values in " { $snippet "seq" } " according to the field formats described by " { $snippet "str" } " into a byte sequence, using little-endian byte order." } ;

HELP: unpack-native
{ $values { "bytes" "a byte sequence" } { "str" "a format string" } { "seq" "a sequence of field values" } }
{ $description "Reads packed data from " { $snippet "bytes" } " according to the field formats described by " { $snippet "str" } " and outputs a sequence containing the unpacked values. Packed data is assumed to have native byte order." } ;

HELP: unpack-be
{ $values { "bytes" "a byte sequence" } { "str" "a format string" } { "seq" "a sequence of field values" } }
{ $description "Reads packed data from " { $snippet "bytes" } " according to the field formats described by " { $snippet "str" } " and outputs a sequence containing the unpacked values. Packed data is assumed to be big-endian." } ;

HELP: unpack-le
{ $values { "bytes" "a byte sequence" } { "str" "a format string" } { "seq" "a sequence of field values" } }
{ $description "Reads packed data from " { $snippet "bytes" } " according to the field formats described by " { $snippet "str" } " and outputs a sequence containing the unpacked values. Packed data is assumed to be little-endian." } ;

HELP: read-packed-native
{ $values { "str" "a format string" } { "seq" "a sequence of field values" } }
{ $description "Reads packed data from " { $link input-stream } " according to the field formats described by " { $snippet "str" } " and outputs a sequence containing the unpacked values. Packed data is assumed to have native byte order." } ;

HELP: read-packed-le
{ $values { "str" "a format string" } { "seq" "a sequence of field values" } }
{ $description "Reads packed data from " { $link input-stream } " according to the field formats described by " { $snippet "str" } " and outputs a sequence containing the unpacked values. Packed data is assumed to be little-endian." } ;

HELP: read-packed-be
{ $values { "str" "a format string" } { "seq" "a sequence of field values" } }
{ $description "Reads packed data from " { $link input-stream } " according to the field formats described by " { $snippet "str" } " and outputs a sequence containing the unpacked values. Packed data is assumed be big-endian." } ;

ARTICLE: "pack" "Packing and Unpacking Binary Data"
"The " { $vocab-link "pack" } " vocabulary implements words for converting between byte buffers and Factor values. It supports reading and writing various numeric formats, and writing null-terminated strings."
$nl
"The serialized format to convert to and from is defined by a string of characters, one per field, with different characters denoting different field types. In cases where there are different signed and unsigned variants for a type, a lower-case letter denotes a signed field and an upper-case letter an unsigned one; in cases where there is no distinction, either case can be used interchangeably. For example, a format string of \"sCCID\" denotes a format consisting of a signed 16-bit integer, followed by two unsigned 8-bit integers, one unsigned 32-bit integer, and one double-precision floating point value."
$nl
"The complete list of supported field types:"
{ $table
    { "C/c" "Unsigned/signed 8-bit int (char)" }
    { "S/s" "Unsigned/signed 16-bit int (short)" }
    { "T/t" "Unsigned/signed 24-bit int" }
    { "I/i" "Unsigned/signed 32-bit int (long)" }
    { "Q/q" "Unsigned/signed 64-bit int (long long)" }
    { "F/f" "Single-precision (32-bit) IEEE floating point" }
    { "D/d" "Double-precision (64-bit) IEEE floating point" }
    { "a"   "Null terminated string (write only)" }
}
$nl
"Words for packing to byte sequences:"
{ $subsections
    pack-native
    pack-be
    pack-le
}
"Words for unpacking from byte sequences:"
{ $subsections
    unpack-native
    unpack-be
    unpack-le
}
"Words for unpacking from an input stream:"
{ $subsections
    read-packed-native
    read-packed-be
    read-packed-le
} ;

ABOUT: "pack"

