USING: help.markup help.syntax byte-arrays strings ;
IN: io.encodings.string

ARTICLE: "io.encodings.string" "Encoding and decoding strings"
"Strings can be encoded or decoded to and from byte arrays through an encoding with the following words:"
{ $subsection encode }
{ $subsection decode } ;

HELP: decode
{ $values { "byte-array" byte-array } { "encoding" "an encoding descriptor" }
    { "string" string } }
{ $description "Decodes the byte array using the given encoding, outputting a string" } ;

HELP: encode 
{ $values { "string" string } { "encoding" "an encoding descriptor" } { "byte-array" byte-array } }
{ $description "Encodes the given string into a byte array with the given encoding." } ;
