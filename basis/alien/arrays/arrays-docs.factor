IN: alien.arrays
USING: help.syntax help.markup byte-arrays alien.c-types ;

ARTICLE: "c-arrays" "C arrays"
"C arrays are allocated in the same manner as other C data; see " { $link "c-byte-arrays" } " and " { $link "malloc" } "."
$nl
"C type specifiers for array types are documented in " { $link "c-types-specs" } "."
$nl
"Specialized sequences are provided for accessing memory as an array of primitive type values. These sequences are implemented in the " { $vocab-link "specialized-arrays" } " and " { $vocab-link "specialized-arrays.direct" } " vocabulary sets. They can also be loaded and constructed through their primitive C types:"
{ $subsection require-c-arrays }
{ $subsection <c-array> }
{ $subsection <c-direct-array> } ;
