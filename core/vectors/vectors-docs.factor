USING: arrays byte-arrays bit-arrays help.markup
help.syntax kernel sbufs strings quotations sequences.private
vectors.private combinators ;
IN: vectors

ARTICLE: "vectors" "Vectors"
"A vector is a resizable mutable sequence of objects. The literal syntax is covered in " { $link "syntax-vectors" } ". Vector words are found in the " { $vocab-link "vectors" } " vocabulary."
$nl
"Vectors form a class:"
{ $subsection vector }
{ $subsection vector? }
"Creating vectors:"
{ $subsection >vector }
{ $subsection <vector> }
"Creating a vector from a single element:"
{ $subsection 1vector }
"If you don't care about initial capacity, a more elegant way to create a new vector is to write:"
{ $code "V{ } clone" } ;

ABOUT: "vectors"

HELP: vector
{ $description "The class of resizable vectors. See " { $link "syntax-vectors" } " for syntax and " { $link "vectors" } " for general information." } ;

HELP: <vector>
{ $values { "n" "a positive integer specifying initial capacity" } { "vector" vector } }
{ $description "Creates a new vector that can hold " { $snippet "n" } " elements before resizing." } ;

HELP: >vector
{ $values { "seq" "a sequence" } { "vector" vector } }
{ $description "Outputs a freshly-allocated vector with the same elements as a given sequence." } ;

HELP: array>vector ( array length -- vector )
{ $values { "array" "an array" } { "length" "a non-negative integer" } { "vector" vector } }
{ $description "Creates a new vector using the array for underlying storage with the specified initial length." }
{ $warning "This word is in the " { $vocab-link "sequences.private" } " vocabulary because it does not perform type or bounds checks. User code should call " { $link >vector } " instead." } ;

HELP: 1vector
{ $values { "x" object } { "vector" vector } }
{ $description "Create a new vector with one element." } ;

HELP: ?push
{ $values { "elt" object } { "seq/f" "a resizable mutable sequence, or " { $link f } } { "seq" "a resizable mutable sequence" } }
{ $description "If the given sequence is " { $link f } ", creates and outputs a new one-element vector holding " { $snippet "elt" } ". Otherwise, pushes " { $snippet "elt" } " onto the given sequence." }
{ $errors "Throws an error if " { $snippet "seq" } " is not resizable, or if the type of " { $snippet "elt" } " is not permitted in " { $snippet "seq" } "." }
{ $side-effects "seq" } ;
