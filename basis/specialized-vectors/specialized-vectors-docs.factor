USING: help.markup help.syntax byte-vectors alien byte-arrays ;
IN: specialized-vectors

HELP: SPECIALIZED-VECTOR:
{ $syntax "SPECIALIZED-VECTOR: type" }
{ $values { "type" "a C type" } }
{ $description "Brings a specialized vector for holding values of " { $snippet "type" } " into the vocabulary search path. The generated words are documented in " { $link "specialized-vector-words" } "." } ;

ARTICLE: "specialized-vector-words" "Specialized vector words"
"The " { $link POSTPONE: SPECIALIZED-VECTOR: } " parsing word generates the specialized vector type if it hasn't been generated already, and adds the following words to the vocabulary search path, where " { $snippet "T" } " is the C type in question:"
{ $table
    { { $snippet "T-vector" } { "The class of vectors with elements of type " { $snippet "T" } } }
    { { $snippet "<T-vector>" } { "Constructor for vectors with elements of type " { $snippet "T" } "; stack effect " { $snippet "( len -- vector )" } } }
    { { $snippet ">T-vector" } { "Converts a sequence into a specialized vector of type " { $snippet "T" } "; stack effect " { $snippet "( seq -- vector )" } } }
    { { $snippet "T-vector{" } { "Literal syntax, consists of a series of values terminated by " { $snippet "}" } } }
}
"Behind the scenes, these words are placed in a vocabulary named " { $snippet "specialized-vectors.instances.T" } ", however this vocabulary should not be placed in a " { $link POSTPONE: USING: } " form directly. Instead, always use " { $link POSTPONE: SPECIALIZED-VECTOR: } ". This ensures that the vocabulary can get generated the first time it is needed." ;

ARTICLE: "specialized-vector-c" "Passing specialized vectors to C functions"
"Each specialized vector has a " { $slot "underlying" } " slot holding a specialized array, which in turn has an " { $slot "underlying" } " slot holding a " { $link byte-array } " with the raw data. Passing a specialized vector as a parameter to a C function call will automatically extract the underlying data. To get at the underlying data directly, call the " { $link >c-ptr } " word on a specialized vector." ;

ARTICLE: "specialized-vectors" "Specialized vectors"
"The " { $vocab-link "specialized-vectors" } " vocabulary implements resizable sequence types for storing machine values in a space-efficient manner without boxing."
{ $subsections
    "specialized-vector-words"
    "specialized-vector-c"
}
"The " { $vocab-link "specialized-arrays" } " vocabulary provides a fixed-length version of this abstraction." ;

ABOUT: "specialized-vectors"
