USING: arrays help.markup help.syntax kernel
kernel.private prettyprint strings vectors sbufs ;
IN: bit-arrays

ARTICLE: "bit-arrays" "Bit arrays"
"Bit array are a fixed-size mutable sequences (" { $link "sequence-protocol" } ") whose elements are either " { $link t } " or " { $link f } ". Each element only uses one bit of storage, hence the name. The literal syntax is covered in " { $link "syntax-bit-arrays" } "."
$nl
"Bit array words are in the " { $vocab-link "bit-arrays" } " vocabulary."
$nl
"Bit arrays play a special role in the C library interface; they can be used to pass binary data back and forth between Factor and C. See " { $link "c-byte-arrays" } "."
$nl
"Bit arrays form a class of objects:"
{ $subsection bit-array }
{ $subsection bit-array? }
"Creating new bit arrays:"
{ $subsection >bit-array }
{ $subsection <bit-array> }
"Efficiently setting and clearing all bits in a bit array:"
{ $subsection set-bits }
{ $subsection clear-bits } ;

ABOUT: "bit-arrays"

HELP: bit-array
{ $description "The class of fixed-length bit arrays. See " { $link "syntax-bit-arrays" } " for syntax and " { $link "bit-arrays" } " for general information." } ;

HELP: <bit-array> ( n -- bit-array )
{ $values { "n" "a non-negative integer" } { "bit-array" "a new " { $link bit-array } } }
{ $description "Creates a new bit array with the given length and all elements initially set to " { $link f } "." } ;

HELP: >bit-array
{ $values { "seq" "a sequence" } { "bit-array" bit-array } }
{ $description "Outputs a freshly-allocated bit array whose elements have the same boolean values as a given sequence." } ;

HELP: clear-bits
{ $values { "bit-array" bit-array } }
{ $description "Sets all elements of the bit array to " { $link f } "." }
{ $notes "Calling this word is more efficient than the following:"
    { $code "[ drop f ] change-each" }
}
{ $side-effects "bit-array" } ;

HELP: set-bits
{ $values { "bit-array" bit-array } }
{ $description "Sets all elements of the bit array to " { $link t } "." }
{ $notes "Calling this word is more efficient than the following:"
    { $code "[ drop t ] change-each" }
}
{ $side-effects "bit-array" } ;
