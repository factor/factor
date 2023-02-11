! Copyright (C) 2008,2011 Daniel Ehrenberg, Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: byte-arrays help.markup help.syntax io.encodings.string
strings ;
IN: io.encodings.string

ARTICLE: "io.encodings.string" "Encoding and decoding strings"
"Strings can be encoded or decoded to and from byte arrays through an encoding by passing "
{ $link "encodings-descriptors" } " to the following words:"
{ $subsections
    encode
    decode
} ;

HELP: decode
{ $values { "byte-array" byte-array } { "encoding" "an encoding descriptor" }
    { "string" string } }
{ $description "Converts an array of bytes to a string, interpreting that array of bytes as a string with the given encoding." }
{ $examples
    { $example "USING: io.encodings.string io.encodings.utf8 prettyprint ;
B{ 230 136 145 231 136 177 228 189 160 } utf8 decode ."
"\"我爱你\""
    }
} ;

HELP: encode
{ $values { "string" string } { "encoding" "an encoding descriptor" } { "byte-array" byte-array } }
{ $description "Converts a string into a byte array, interpreting that string with the given encoding." }
{ $examples
    { $example "USING: io.encodings.string io.encodings.utf8 prettyprint ;
\"我爱你\" utf8 encode ."
"B{ 230 136 145 231 136 177 228 189 160 }"
    }
} ;
