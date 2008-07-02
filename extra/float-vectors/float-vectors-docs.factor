USING: arrays float-arrays help.markup help.syntax kernel
float-vectors.private combinators ;
IN: float-vectors

ARTICLE: "float-vectors" "Float vectors"
"A float vector is a resizable mutable sequence of unsigned floats. Float vector words are found in the " { $vocab-link "float-vectors" } " vocabulary."
$nl
"Float vectors form a class:"
{ $subsection float-vector }
{ $subsection float-vector? }
"Creating float vectors:"
{ $subsection >float-vector }
{ $subsection <float-vector> }
"Literal syntax:"
{ $subsection POSTPONE: FV{ }
"If you don't care about initial capacity, a more elegant way to create a new float vector is to write:"
{ $code "FV{ } clone" } ;

ABOUT: "float-vectors"

HELP: float-vector
{ $description "The class of resizable float vectors. See " { $link "float-vectors" } " for information." } ;

HELP: <float-vector>
{ $values { "n" "a positive integer specifying initial capacity" } { "float-vector" float-vector } }
{ $description "Creates a new float vector that can hold " { $snippet "n" } " floats before resizing." } ;

HELP: >float-vector
{ $values { "seq" "a sequence" } { "float-vector" float-vector } }
{ $description "Outputs a freshly-allocated float vector with the same elements as a given sequence." }
{ $errors "Throws an error if the sequence contains elements other than real numbers." } ;

HELP: FV{
{ $syntax "FV{ elements... }" }
{ $values { "elements" "a list of real numbers" } }
{ $description "Marks the beginning of a literal float vector. Literal float vectors are terminated by " { $link POSTPONE: } } "." } 
{ $examples { $code "FV{ 1.0 2.0 3.0 }" } } ;
