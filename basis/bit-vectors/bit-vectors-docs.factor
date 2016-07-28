USING: help.markup help.syntax sequences ;
IN: bit-vectors

ARTICLE: "bit-vectors" "Bit vectors"
"A bit vector is a resizable mutable sequence of bits. Bit vector words are found in the " { $vocab-link "bit-vectors" } " vocabulary."
$nl
"Bit vectors form a class:"
{ $subsections
    bit-vector
    bit-vector?
}
"Creating bit vectors:"
{ $subsections
    >bit-vector
    <bit-vector>
}
"Literal syntax:"
{ $subsections POSTPONE: ?V{ }
"If you don't care about initial capacity, a more elegant way to create a new bit vector is to write:"
{ $code "?V{ } clone" } ;

ABOUT: "bit-vectors"

HELP: bit-vector
{ $class-description "The class of resizable bit vectors. See " { $link "bit-vectors" } " for information." } ;

HELP: <bit-vector>
{ $values { "capacity" "a positive integer specifying initial capacity" } { "vector" bit-vector } }
{ $description "Creates a new bit vector that can hold " { $snippet "n" } " bits before resizing." } ;

HELP: >bit-vector
{ $values { "seq" sequence } { "vector" bit-vector } }
{ $description "Outputs a freshly-allocated bit vector with the same elements as a given sequence." } ;

HELP: ?V{
{ $syntax "?V{ elements... }" }
{ $values { "elements" "a list of booleans" } }
{ $description "Marks the beginning of a literal bit vector. Literal bit vectors are terminated by " { $link POSTPONE: } } "." }
{ $examples { $code "?V{ t f t }" } } ;
