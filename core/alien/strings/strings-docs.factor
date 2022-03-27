USING: alien byte-arrays help.markup help.syntax sequences
strings ;
IN: alien.strings

HELP: string>alien
{ $values { "string" string } { "encoding" "an encoding descriptor" } { "byte-array" byte-array } }
{ $description "Encodes a string together with a trailing null code point using the given encoding, and stores the resulting bytes in a freshly-allocated byte array." }
{ $errors "Throws an error if the string contains null characters, or characters not representable in the given encoding." } ;

HELP: alien>string
{ $values { "c-ptr" c-ptr } { "encoding" "an encoding descriptor" } { "string/f" "a string or " { $link f } } }
{ $description "Reads a null-terminated C string from the specified address with the given encoding." } ;

HELP: string>symbol
{ $values { "str/seq" { $or string sequence } } { "alien" alien } }
{ $description "Converts the string to a format which is a valid symbol name for the Factor VM's compiled code linker. By performing this conversion ahead of time, the image loader can run without allocating memory."
$nl
"On all platforms, symbols are ASCII strings." } ;

ABOUT: "c-strings"
