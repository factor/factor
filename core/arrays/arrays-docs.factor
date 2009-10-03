USING: help.markup help.syntax
kernel kernel.private prettyprint sequences.private sequences ;
IN: arrays

ARTICLE: "arrays-unsafe" "Unsafe array operations"
"These two words are used internally by the Factor implementation. User code should never need to call them; instead use " { $link nth } " and " { $link set-nth } "."
{ $subsections
    array-nth
    set-array-nth
} ;

ARTICLE: "arrays" "Arrays"
"The " { $vocab-link "arrays" } " vocabulary implements fixed-size mutable sequences which support the " { $link "sequence-protocol" } "."
$nl
"The " { $vocab-link "arrays" } " vocabulary only includes words for creating new arrays. To access and modify array elements, use " { $link "sequences" } " in the " { $vocab-link "sequences" } " vocabulary."
$nl
"Array literal syntax is documented in " { $link "syntax-arrays" } ". Resizable arrays also exist and are known as " { $link "vectors" } "."
$nl
"Arrays form a class of objects:"
{ $subsections
    array
    array?
}
"Creating new arrays:"
{ $subsections
    >array
    <array>
}
"Creating an array from several elements on the stack:"
{ $subsections
    1array
    2array
    3array
    4array
}
"The class of two-element arrays:"
{ $subsections pair }
"Arrays can be accessed without bounds checks in a pointer unsafe way."
{ $subsections "arrays-unsafe" } ;

ABOUT: "arrays"

HELP: array
{ $description "The class of fixed-length arrays. See " { $link "syntax-arrays" } " for syntax and " { $link "arrays" } " for general information." } ;

HELP: <array> ( n elt -- array )
{ $values { "n" "a non-negative integer" } { "elt" "an initial element" } { "array" "a new array" } }
{ $description "Creates a new array with the given length and all elements initially set to " { $snippet "elt" } "." } ;

HELP: >array
{ $values { "seq" "a sequence" } { "array" array } }
{ $description "Outputs a freshly-allocated array with the same elements as a given sequence." } ;

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
