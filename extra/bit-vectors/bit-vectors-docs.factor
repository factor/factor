USING: arrays bit-arrays help.markup help.syntax kernel
bit-vectors.private combinators ;
IN: bit-vectors

ARTICLE: "bit-vectors" "Bit vectors"
"A bit vector is a resizable mutable sequence of bits. The literal syntax is covered in " { $link "syntax-bit-vectors" } ". Bit vector words are found in the " { $vocab-link "bit-vectors" } " vocabulary."
$nl
"Bit vectors form a class:"
{ $subsection bit-vector }
{ $subsection bit-vector? }
"Creating bit vectors:"
{ $subsection >bit-vector }
{ $subsection <bit-vector> }
"Literal syntax:"
{ $subsection POSTPONE: ?V{ }
"If you don't care about initial capacity, a more elegant way to create a new bit vector is to write:"
{ $code "?V{ } clone" } ;

ABOUT: "bit-vectors"

HELP: bit-vector
{ $description "The class of resizable bit vectors. See " { $link "syntax-bit-vectors" } " for syntax and " { $link "bit-vectors" } " for general information." } ;

HELP: <bit-vector>
{ $values { "n" "a positive integer specifying initial capacity" } { "bit-vector" bit-vector } }
{ $description "Creates a new bit vector that can hold " { $snippet "n" } " bits before resizing." } ;

HELP: >bit-vector
{ $values { "seq" "a sequence" } { "bit-vector" bit-vector } }
{ $description "Outputs a freshly-allocated bit vector with the same elements as a given sequence." } ;

HELP: bit-array>vector
{ $values { "bit-array" "an array" } { "length" "a non-negative integer" } { "bit-vector" bit-vector } }
{ $description "Creates a new bit vector using the array for underlying storage with the specified initial length." }
{ $warning "This word is in the " { $vocab-link "bit-vectors.private" } " vocabulary because it does not perform type or bounds checks. User code should call " { $link >bit-vector } " instead." } ;

HELP: ?V{
{ $syntax "?V{ elements... }" }
{ $values { "elements" "a list of booleans" } }
{ $description "Marks the beginning of a literal bit vector. Literal bit vectors are terminated by " { $link POSTPONE: } } "." } 
{ $examples { $code "?V{ t f t }" } } ;

