USING: help.markup help.syntax kernel sequences ;
IN: vectors

ARTICLE: "vectors" "Vectors"
"The " { $vocab-link "vectors" } " vocabulary implements resizable mutable sequence which support the " { $link "sequence-protocol" } "."
$nl
"The " { $vocab-link "vectors" } " vocabulary only includes words for creating new vectors. To access and modify vector elements, use " { $link "sequences" } " in the " { $vocab-link "sequences" } " vocabulary."
$nl
"Vector literal syntax is documented in " { $link "syntax-vectors" } "."
$nl
"Vectors are intended to be used with " { $link "sequences-destructive" } ". Code that does not modify sequences in-place can use fixed-size arrays without loss of generality; see " { $link "arrays" } "."
$nl
"Vectors form a class of objects:"
{ $subsections
    vector
    vector?
}
"Creating new vectors:"
{ $subsections
    >vector
    <vector>
}
"Creating a vector from a single element:"
{ $subsections 1vector }
"If you don't care about initial capacity, an elegant way to create a new vector is to write:"
{ $code "V{ } clone" } ;

ABOUT: "vectors"

HELP: vector
{ $class-description "The class of resizable vectors. See " { $link "syntax-vectors" } " for syntax and " { $link "vectors" } " for general information." } ;

HELP: <vector>
{ $values { "n" "a positive integer specifying initial capacity" } { "vector" vector } }
{ $description "Creates a new vector that can hold " { $snippet "n" } " elements before resizing." } ;

HELP: >vector
{ $values { "seq" sequence } { "vector" vector } }
{ $description "Outputs a freshly-allocated vector with the same elements as a given sequence." } ;

HELP: 1vector
{ $values { "x" object } { "vector" vector } }
{ $description "Create a new vector with one element." } ;

HELP: ?push
{ $values { "elt" object } { "seq/f" { $maybe "a resizable mutable sequence" } } { "seq" "a resizable mutable sequence" } }
{ $description "If the given sequence is " { $link f } ", creates and outputs a new one-element vector holding " { $snippet "elt" } ". Otherwise, pushes " { $snippet "elt" } " onto the given sequence." }
{ $errors "Throws an error if " { $snippet "seq" } " is not resizable, or if the type of " { $snippet "elt" } " is not permitted in " { $snippet "seq" } "." }
{ $side-effects "seq" } ;
