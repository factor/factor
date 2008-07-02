USING: arrays bit-arrays vectors strings sbufs
kernel help.markup help.syntax math ;
IN: float-arrays

ARTICLE: "float-arrays" "Float arrays"
"Float arrays are fixed-size mutable sequences (" { $link "sequence-protocol" } ") whose elements are instances of " { $link float } ". Elements are unboxed, hence the memory usage is lower than an equivalent " { $link array } " of floats. The literal syntax is covered in " { $link "syntax-float-arrays" } "."
$nl
"Float array words are in the " { $vocab-link "float-arrays" } " vocabulary."
$nl
"Float arrays play a special role in the C library interface; they can be used to pass binary data back and forth between Factor and C. See " { $link "c-byte-arrays" } "."
$nl
"Float arrays form a class of objects."
{ $subsection float-array }
{ $subsection float-array? }
"There are several ways to construct float arrays."
{ $subsection >float-array }
{ $subsection <float-array> }
"Creating a float array from several elements on the stack:"
{ $subsection 1float-array }
{ $subsection 2float-array }
{ $subsection 3float-array }
{ $subsection 4float-array }
"Float array literal syntax:"
{ $subsection POSTPONE: F{ } ;

ABOUT: "float-arrays"

HELP: F{
{ $syntax "F{ elements... }" }
{ $values { "elements" "a list of real numbers" } }
{ $description "Marks the beginning of a literal float array. Literal float arrays are terminated by " { $link POSTPONE: } } "." } 
{ $examples { $code "F{ 1.0 2.0 3.0 }" } } ;

HELP: float-array
{ $description "The class of float arrays. See " { $link "syntax-float-arrays" } " for syntax and " { $link "float-arrays" } " for general information." } ;

HELP: <float-array> ( n -- float-array )
{ $values { "n" "a non-negative integer" } { "float-array" "a new float array" } }
{ $description "Creates a new float array holding " { $snippet "n" } " floats with all elements initially set to " { $snippet "0.0" } "." } ;

HELP: >float-array
{ $values { "seq" "a sequence" } { "float-array" float-array } }
{ $description "Outputs a freshly-allocated float array whose elements have the same floating-point values as a given sequence." }
{ $errors "Throws an error if the sequence contains elements other than real numbers." } ;

HELP: 1float-array
{ $values { "x" object } { "array" float-array } }
{ $description "Create a new float array with one element." } ;

{ 1array 2array 3array 4array } related-words

HELP: 2float-array
{ $values { "x" object } { "y" object } { "array" float-array } }
{ $description "Create a new float array with two elements, with " { $snippet "x" } " appearing first." } ;

HELP: 3float-array
{ $values { "x" object } { "y" object } { "z" object } { "array" float-array } }
{ $description "Create a new float array with three elements, with " { $snippet "x" } " appearing first." } ;

HELP: 4float-array
{ $values { "w" object } { "x" object } { "y" object } { "z" object } { "array" float-array } }
{ $description "Create a new float array with four elements, with " { $snippet "w" } " appearing first." } ;
