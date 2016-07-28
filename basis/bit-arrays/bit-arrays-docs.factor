USING: help.markup help.syntax math sequences ;
IN: bit-arrays

ARTICLE: "bit-arrays" "Bit arrays"
"Bit array are a fixed-size mutable sequences (" { $link "sequence-protocol" } ") whose elements are either " { $link t } " or " { $link f } ". Each element only uses one bit of storage, hence the name."
$nl
"Bit array words are in the " { $vocab-link "bit-arrays" } " vocabulary."
$nl
"Bit arrays play a special role in the C library interface; they can be used to pass binary data back and forth between Factor and C. See " { $link "c-pointers" } "."
$nl
"Bit arrays form a class of objects:"
{ $subsections
    bit-array
    bit-array?
}
"Creating new bit arrays:"
{ $subsections
    >bit-array
    <bit-array>
}
"Efficiently setting and clearing all bits in a bit array:"
{ $subsections
    set-bits
    clear-bits
}
"Converting between unsigned integers and their binary representation:"
{ $subsections
    integer>bit-array
    bit-array>integer
}
"Bit array literal syntax:"
{ $subsections POSTPONE: ?{ } ;

ABOUT: "bit-arrays"

HELP: ?{
{ $syntax "?{ elements... }" }
{ $values { "elements" "a list of booleans" } }
{ $description "Marks the beginning of a literal bit array. Literal bit arrays are terminated by " { $link POSTPONE: } } "." }
{ $examples { $code "?{ t f t }" } } ;

HELP: bit-array
{ $class-description "The class of fixed-length bit arrays." } ;

HELP: <bit-array>
{ $values { "n" "a non-negative integer" } { "bit-array" "a new " { $link bit-array } } }
{ $description "Creates a new bit array with the given length and all elements initially set to " { $link f } "." } ;

HELP: >bit-array
{ $values { "seq" sequence } { "bit-array" bit-array } }
{ $description "Outputs a freshly-allocated bit array whose elements have the same boolean values as a given sequence." } ;

HELP: clear-bits
{ $values { "bit-array" bit-array } }
{ $description "Sets all elements of the bit array to " { $link f } "." }
{ $notes "Calling this word is more efficient than the following:"
    { $code "[ drop f ] map! drop" }
}
{ $side-effects "bit-array" } ;

HELP: set-bits
{ $values { "bit-array" bit-array } }
{ $description "Sets all elements of the bit array to " { $link t } "." }
{ $notes "Calling this word is more efficient than the following:"
    { $code "[ drop t ] map! drop" }
}
{ $side-effects "bit-array" } ;

HELP: integer>bit-array
{ $values { "n" integer } { "bit-array" bit-array } }
{ $description "Outputs a freshly-allocated bit array whose elements correspond to the bits in the binary representation of the given unsigned integer value." }
{ $notes "The bits of the integer are stored in the resulting bit array in order of ascending significance, least significant bit first. This word will fail if passed a negative integer. If you want the two's-complement binary representation of a negative number, use " { $link bitnot } " to get the complement of the number first. This word works with fixnums or bignums of any size; it is not limited by fixnum size or machine word size." } ;

HELP: bit-array>integer
{ $values { "bit-array" bit-array } { "n" integer } }
{ $description "Outputs the unsigned integer whose binary representation corresponds to the contents of the given bit array." }
{ $notes "The bits of the integer are taken from the bit array in order of ascending significance, least significant bit first. This word is able to return fixnums or bignums of any size; it is not limited by fixnum size or machine word size." } ;
