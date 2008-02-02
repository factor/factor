USING: arrays float-arrays help.markup help.syntax kernel
float-vectors.private combinators ;
IN: float-vectors

ARTICLE: "float-vectors" "Float vectors"
"A float vector is a resizable mutable sequence of unsigned floats. The literal syntax is covered in " { $link "syntax-float-vectors" } ". Float vector words are found in the " { $vocab-link "float-vectors" } " vocabulary."
$nl
"Float vectors form a class:"
{ $subsection float-vector }
{ $subsection float-vector? }
"Creating float vectors:"
{ $subsection >float-vector }
{ $subsection <float-vector> }
"If you don't care about initial capacity, a more elegant way to create a new float vector is to write:"
{ $code "BV{ } clone" } ;

ABOUT: "float-vectors"

HELP: float-vector
{ $description "The class of resizable float vectors. See " { $link "syntax-float-vectors" } " for syntax and " { $link "float-vectors" } " for general information." } ;

HELP: <float-vector>
{ $values { "n" "a positive integer specifying initial capacity" } { "float-vector" float-vector } }
{ $description "Creates a new float vector that can hold " { $snippet "n" } " floats before resizing." } ;

HELP: >float-vector
{ $values { "seq" "a sequence" } { "float-vector" float-vector } }
{ $description "Outputs a freshly-allocated float vector with the same elements as a given sequence." }
{ $errors "Throws an error if the sequence contains elements other than real numbers." } ;

HELP: float-array>vector
{ $values { "float-array" "an array" } { "length" "a non-negative integer" } { "float-vector" float-vector } }
{ $description "Creates a new float vector using the array for underlying storage with the specified initial length." }
{ $warning "This word is in the " { $vocab-link "float-vectors.private" } " vocabulary because it does not perform type or bounds checks. User code should call " { $link >float-vector } " instead." } ;
