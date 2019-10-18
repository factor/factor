USING: arrays bit-arrays vectors strings sbufs
kernel help.markup help.syntax ;
IN: byte-arrays

ARTICLE: "byte-arrays" "Byte arrays"
"Byte arrays are fixed-size mutable sequences (" { $link "sequence-protocol" } ") whose elements are integers in the range 0-255, inclusive. Each element only uses one byte of storage, hence the name. The literal syntax is covered in " { $link "syntax-byte-arrays" } "."
$nl
"Byte array words are in the " { $vocab-link "byte-arrays" } " vocabulary."
$nl
"Byte arrays play a special role in the C library interface; they can be used to pass binary data back and forth between Factor and C. See " { $link "c-byte-arrays" } "."
$nl
"Byte arrays form a class of objects."
{ $subsection byte-array }
{ $subsection byte-array? }
"There are several ways to construct byte arrays."
{ $subsection >byte-array }
{ $subsection <byte-array> } ;

ABOUT: "byte-arrays"

HELP: byte-array
{ $description "The class of byte arrays. See " { $link "syntax-byte-arrays" } " for syntax and " { $link "byte-arrays" } " for general information." } ;

HELP: <byte-array> ( n -- byte-array )
{ $values { "n" "a non-negative integer" } { "byte-array" "a new byte array" } }
{ $description "Creates a new byte array holding " { $snippet "n" } " bytes." } ;

HELP: >byte-array
{ $values { "seq" "a sequence" } { "byte-array" byte-array } }
{ $description "Outputs a freshly-allocated byte array whose elements have the same boolean values as a given sequence." }
{ $errors "Throws an error if the sequence contains elements other than integers." } ;
