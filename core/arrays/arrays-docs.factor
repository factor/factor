USING: byte-arrays bit-arrays help.markup help.syntax
kernel kernel.private prettyprint strings sbufs vectors
quotations sequences.private ;
IN: arrays

ARTICLE: "arrays" "Arrays"
"Arrays are fixed-size mutable sequences (" { $link "sequence-protocol" } "). The literal syntax is covered in " { $link "syntax-arrays" } ". Resizable arrays also exist and are called vectors; see " { $link "vectors" } "."
$nl
"Array words are in the " { $vocab-link "arrays" } " vocabulary. Unsafe implementation words are in the " { $vocab-link "sequences.private" } " vocabulary."
$nl
"Arrays form a class of objects:"
{ $subsection array }
{ $subsection array? }
"Creating new arrays:"
{ $subsection >array }
{ $subsection <array> }
"Creating an array from several elements on the stack:"
{ $subsection 1array }
{ $subsection 2array }
{ $subsection 3array }
{ $subsection 4array }
"Arrays can be accessed without bounds checks in a pointer unsafe way."
{ $subsection array-nth }
{ $subsection set-array-nth }
"The class of two-element arrays:"
{ $subsection pair } ;

ABOUT: "arrays"

HELP: array
{ $description "The class of fixed-length arrays. See " { $link "syntax-arrays" } " for syntax and " { $link "arrays" } " for general information." } ;

HELP: <array> ( n elt -- array )
{ $values { "n" "a non-negative integer" } { "elt" "an initial element" } { "array" "a new array" } }
{ $description "Creates a new array with the given length and all elements initially set to " { $snippet "elt" } "." } ;

{ <array> <quotation> <string> <sbuf> <vector> <byte-array> <bit-array> }
related-words

HELP: >array
{ $values { "seq" "a sequence" } { "array" array } }
{ $description "Outputs a freshly-allocated array with the same elements as a given sequence." } ;

{ >array >quotation >string >sbuf >vector >byte-array >bit-array }
related-words

HELP: 1array
{ $values { "x" object } { "array" array } }
{ $description "Create a new array with one element." } ;

{ 1array 2array 3array 4array } related-words

HELP: 2array
{ $values { "x" object } { "y" object } { "array" array } }
{ $description "Create a new array with two elements, with " { $snippet "x" } " appearing first." } ;

HELP: 3array
{ $values { "x" object } { "y" object } { "z" object } { "array" array } }
{ $description "Create a new array with three elements, with " { $snippet "x" } " appearing first." } ;

HELP: 4array
{ $values { "w" object } { "x" object } { "y" object } { "z" object } { "array" array } }
{ $description "Create a new array with four elements, with " { $snippet "w" } " appearing first." } ;

HELP: resize-array ( n array -- newarray )
{ $values { "n" "a non-negative integer" } { "array" array } { "newarray" "a new array" } }
{ $description "Creates a new array of " { $snippet "n" } " elements. The contents of the existing array are copied into the new array; if the new array is shorter, only an initial segment is copied, and if the new array is longer the remaining space is filled in with "{ $link f } "." } ;

HELP: pair
{ $class-description "The class of two-element arrays, known as pairs." } ;
