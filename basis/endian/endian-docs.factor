USING: help.markup help.syntax io math byte-arrays ;
IN: endian

ARTICLE: "stream-binary" "Working with binary data"
"Stream words on binary streams only read and write byte arrays. Packed binary integers can be read and written by converting to and from sequences of bytes. Floating point numbers can be read and written by converting them into a their bitwise integer representation (" { $link "floats" } ")."
$nl
"There are two ways to order the bytes making up an integer; " { $emphasis "little endian" } " byte order outputs the least significant byte first, and the most significant byte last, whereas " { $emphasis "big endian" } " is the other way around."
$nl
"Consider the hexadecimal integer " { $snippet "0xcafebabe" } ". Little endian byte order yields the following sequence of bytes:"
{ $table
    { "Byte:" "1" "2" "3" "4" }
    { "Value:" { $snippet "be" } { $snippet "ba" } { $snippet "fe" } { $snippet "ca" } }
}
"Compare this with big endian byte order:"
{ $table
    { "Byte:" "1" "2" "3" "4" }
    { "Value:" { $snippet "ca" } { $snippet "fe" } { $snippet "ba" } { $snippet "be" } }
}
"Two words convert a sequence of bytes into an integer:"
{ $subsections
    be>
    le>
}
"Two words convert an integer into a sequence of bytes:"
{ $subsections
    >be
    >le
} ;

ABOUT: "stream-binary"

HELP: be>
{ $values { "seq" { $sequence "bytes" } } { "x" "a non-negative integer" } }
{ $description "Converts a sequence of bytes in big endian order into an unsigned integer." } ;

HELP: le>
{ $values { "seq" { $sequence "bytes" } } { "x" "a non-negative integer" } }
{ $description "Converts a sequence of bytes in little endian order into an unsigned integer." } ;

HELP: nth-byte
{ $values { "x" integer } { "n" "a non-negative integer" } { "b" "a byte" } }
{ $description "Outputs the " { $snippet "n" } "th least significant byte of the sign-extended 2's complement representation of " { $snippet "x" } "." } ;

HELP: >le
{ $values { "x" integer } { "n" "a non-negative integer" } { "byte-array" byte-array } }
{ $description "Converts an integer " { $snippet "x" } " into a string of " { $snippet "n" } " bytes in little endian order. Truncation will occur if the integer is not in the range " { $snippet "[-2^(8n),2^(8n))" } "." } ;

HELP: >be
{ $values { "x" integer } { "n" "a non-negative integer" } { "byte-array" byte-array } }
{ $description "Converts an integer " { $snippet "x" } " into a string of " { $snippet "n" } " bytes in big endian order. Truncation will occur if the integer is not in the range " { $snippet "[-2^(8n),2^(8n))" } "." } ;
