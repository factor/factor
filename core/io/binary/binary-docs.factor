USING: help.markup help.syntax io math byte-arrays ;
IN: io.binary

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
}
"Words for taking larger integers apart into smaller integers:"
{ $subsections
    d>w/w
    w>h/h
    h>b/b
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

HELP: mask-byte
{ $values { "x" integer } { "y" "a non-negative integer" } }
{ $description "Masks off the least significant 8 bits of an integer." } ;

HELP: d>w/w
{ $values { "d" "a 64-bit integer" } { "w1" "a 32-bit integer" } { "w2" "a 32-bit integer" } }
{ $description "Outputs two integers, the least followed by the most significant 32 bits of the input." } ;

HELP: w>h/h
{ $values { "w" "a 32-bit integer" } { "h1" "a 16-bit integer" } { "h2" "a 16-bit integer" } }
{ $description "Outputs two integers, the least followed by the most significant 16 bits of the input." } ;

HELP: h>b/b
{ $values { "h" "a 16-bit integer" } { "b1" "an 8-bit integer" } { "b2" "an 8-bit integer" } }
{ $description "Outputs two integers, the least followed by the most significant 8 bits of the input." } ;
