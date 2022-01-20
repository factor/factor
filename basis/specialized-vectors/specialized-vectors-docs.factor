USING: alien byte-arrays classes.struct help.markup help.syntax ;
IN: specialized-vectors

HELP: SPECIALIZED-VECTOR:
{ $syntax "SPECIALIZED-VECTOR: type" }
{ $values { "type" "a C type" } }
{ $description "Brings a specialized vector for holding values of " { $snippet "type" } " into the vocabulary search path. The generated words are documented in " { $link "specialized-vector-words" } "." } ;

HELP: SPECIALIZED-VECTORS:
{ $syntax "SPECIALIZED-VECTORS: type type type ... ;" }
{ $values { "type" "a C type" } }
{ $description "Brings a set of specialized vectors for holding values of each " { $snippet "type" } " into the vocabulary search path. The generated words are documented in " { $link "specialized-vector-words" } "." } ;

{ POSTPONE: SPECIALIZED-VECTOR: POSTPONE: SPECIALIZED-VECTORS: } related-words

ARTICLE: "specialized-vector-words" "Specialized vector words"
"The " { $link POSTPONE: SPECIALIZED-VECTOR: } " parsing word generates the specialized vector type if it hasn't been generated already, and adds the following words to the vocabulary search path, where " { $snippet "T" } " is the C type in question:"
{ $table
    { { $snippet "T-vector" } { "The class of vectors with elements of type " { $snippet "T" } } }
    { { $snippet "<T-vector>" } { "Constructor for vectors with elements of type " { $snippet "T" } "; stack effect " { $snippet "( len -- vector )" } } }
    { { $snippet ">T-vector" } { "Converts a sequence into a specialized vector of type " { $snippet "T" } "; stack effect " { $snippet "( seq -- vector )" } } }
    { { $snippet "T-vector{" } { "Literal syntax, consists of a series of values terminated by " { $snippet "}" } } }
}
"Behind the scenes, these words are placed in a vocabulary named " { $snippet "specialized-vectors.instances.T" } ", however this vocabulary should not be placed in a " { $link POSTPONE: USING: } " form directly. Instead, always use " { $link POSTPONE: SPECIALIZED-VECTOR: } ". This ensures that the vocabulary can get generated the first time it is needed." ;

HELP: push-new
{ $values { "vector" "a specialized vector of structs" } { "new" "a new value of the specialized vector's type" } }
{ $description "Grows " { $snippet "vector" } ", increasing its length by one, and outputs a " { $link struct } " object wrapping the newly allocated storage." }
{ $notes "This word allows struct objects to be streamed into a struct vector efficiently without excessive copying. The typical Factor idiom for pushing a new object onto a vector, when used with struct vectors, will allocate and copy a temporary struct object:"
{ $code "foo <struct>
    5 >>a
    6 >>b
foo-vector{ } clone push" }
"By using " { $snippet "push-new" } ", the new struct can be allocated directly from the vector and the intermediate copy can be avoided:"
{ $code "foo-vector{ } clone push-new
    5 >>a
    6 >>b
    drop" } } ;

ARTICLE: "specialized-vector-c" "Passing specialized vectors to C functions"
"Each specialized vector has a " { $slot "underlying" } " slot holding a specialized array, which in turn has an " { $slot "underlying" } " slot holding a " { $link byte-array } " with the raw data. Passing a specialized vector as a parameter to a C function call will automatically extract the underlying data. To get at the underlying data directly, call the " { $link >c-ptr } " word on a specialized vector." ;

ARTICLE: "specialized-vectors" "Specialized vectors"
"The " { $vocab-link "specialized-vectors" } " vocabulary implements resizable sequence types for storing machine values in a space-efficient manner without boxing."
$nl
"A specialized vector type needs to be generated for each element type. This is done with parsing words:"
{ $subsections
    POSTPONE: SPECIALIZED-VECTOR:
    POSTPONE: SPECIALIZED-VECTORS:
}
{ $subsections
    "specialized-vector-words"
    "specialized-vector-c"
}
"This vocabulary also contains special vector operations for making efficient use of specialized vector types:"
{ $subsections
    push-new
}
"The " { $vocab-link "specialized-arrays" } " vocabulary provides a fixed-length version of this abstraction." ;

ABOUT: "specialized-vectors"
