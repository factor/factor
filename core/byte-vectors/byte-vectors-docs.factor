USING: arrays byte-arrays help.markup help.syntax kernel
byte-vectors.private combinators ;
IN: byte-vectors

ARTICLE: "byte-vectors" "Byte vectors"
"A byte vector is a resizable mutable sequence of unsigned bytes. The literal syntax is covered in " { $link "syntax-byte-vectors" } ". Byte vector words are found in the " { $vocab-link "byte-vectors" } " vocabulary."
$nl
"Byte vectors form a class:"
{ $subsection byte-vector }
{ $subsection byte-vector? }
"Creating byte vectors:"
{ $subsection >byte-vector }
{ $subsection <byte-vector> }
"If you don't care about initial capacity, a more elegant way to create a new byte vector is to write:"
{ $code "BV{ } clone" } ;

ABOUT: "byte-vectors"

HELP: byte-vector
{ $description "The class of resizable byte vectors. See " { $link "syntax-byte-vectors" } " for syntax and " { $link "byte-vectors" } " for general information." } ;

HELP: <byte-vector>
{ $values { "n" "a positive integer specifying initial capacity" } { "byte-vector" byte-vector } }
{ $description "Creates a new byte vector that can hold " { $snippet "n" } " bytes before resizing." } ;

HELP: >byte-vector
{ $values { "seq" "a sequence" } { "vector" vector } }
{ $description "Outputs a freshly-allocated byte vector with the same elements as a given sequence." }
{ $errors "Throws an error if the sequence contains elements other than integers." } ;

HELP: byte-array>vector
{ $values { "byte-array" "an array" } { "length" "a non-negative integer" } { "byte-vector" byte-vector } }
{ $description "Creates a new byte vector using the array for underlying storage with the specified initial length." }
{ $warning "This word is in the " { $vocab-link "byte-vectors.private" } " vocabulary because it does not perform type or bounds checks. User code should call " { $link >byte-vector } " instead." } ;
