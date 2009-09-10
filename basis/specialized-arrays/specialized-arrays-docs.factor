USING: help.markup help.syntax byte-arrays alien ;
IN: specialized-arrays

HELP: SPECIALIZED-ARRAY:
{ $syntax "SPECIALIZED-ARRAY: type" }
{ $values { "type" "a C type" } }
{ $description "Brings a specialized array for holding values of " { $snippet "type" } " into the vocabulary search path. The generated words are documented in " { $link "specialized-array-words" } "." } ;

ARTICLE: "specialized-array-words" "Specialized array words"
"The " { $link POSTPONE: SPECIALIZED-ARRAY: } " parsing word generates the specialized array type if it hasn't been generated already, and adds the following words to the vocabulary search path, where " { $snippet "T" } " is the C type in question:"
{ $table
    { { $snippet "T-array" } { "The class of arrays with elements of type " { $snippet "T" } } }
    { { $snippet "<T-array>" } { "Constructor for arrays with elements of type " { $snippet "T" } "; stack effect " { $snippet "( len -- array )" } } }
    { { $snippet "(T-array)" } { "Constructor for arrays with elements of type " { $snippet "T" } ", where the initial contents are uninitialized; stack effect " { $snippet "( len -- array )" } } }
    { { $snippet "malloc-T-array" } { "Constructor for arrays with elements of type " { $snippet "T" } " backed by newly-allocated unmanaged memory; stack effect " { $snippet "( alien len -- array )" } } }
    { { $snippet "<direct-T-array>" } { "Constructor for arrays with elements of type " { $snippet "T" } " backed by raw memory; stack effect " { $snippet "( alien len -- array )" } } }
    { { $snippet "byte-array>T-array" } { "Converts a byte array into a specialized array by interpreting the bytes in as machine-specific values. Code which uses this word is unportable" } }
    { { $snippet ">T-array" } { "Converts a sequence into a specialized array of type " { $snippet "T" } "; stack effect " { $snippet "( seq -- array )" } } }
    { { $snippet "T-array{" } { "Literal syntax, consists of a series of values terminated by " { $snippet "}" } } }
}
"Behind the scenes, these words are placed in a vocabulary named " { $snippet "specialized-arrays.instances.T" } ", however this vocabulary should not be placed in a " { $link POSTPONE: USING: } " form directly. Instead, always use " { $link POSTPONE: SPECIALIZED-ARRAY: } ". This ensures that the vocabulary can get generated the first time it is needed." ;

ARTICLE: "specialized-array-c" "Passing specialized arrays to C functions"
"Each specialized array has a " { $slot "underlying" } " slot holding a " { $link byte-array } " with the raw data. Passing a specialized array as a parameter to a C function call will automatically extract the underlying data. To get at the underlying data directly, call the " { $link >c-ptr } " word on a specialized array." ;

ARTICLE: "specialized-array-math" "Vector arithmetic with specialized arrays"
"Each specialized array with a numeric type generates specialized versions of the " { $link "math-vectors" } " words. The compiler substitutes calls for these words if it can statically determine input types. The " { $snippet "optimized." } " word in the " { $vocab-link "compiler.tree.debugger" } " vocabulary can be used to determine if this optimization is being performed for a particular piece of code." ;

ARTICLE: "specialized-array-examples" "Specialized array examples"
"Let's import specialized float arrays:"
{ $code "USING: specialized-arrays math.constants math.functions ;" "SPECIALIZED-ARRAY: float" }
"Creating a float array with 3 elements:"
{ $code "1.0 [ sin ] [ cos ] [ tan ] tri float-array{ } 3sequence ." }
"Create a float array and sum the elements:"
{ $code
    "1000 iota [ 1000 /f pi * sin ] float-array{ } map-as"
    "0.0 [ + ] reduce ."
} ;

ARTICLE: "specialized-arrays" "Specialized arrays"
"The " { $vocab-link "specialized-arrays" } " vocabulary implements fixed-length sequence types for storing machine values in a space-efficient manner without boxing."
$nl
"A specialized array type needs to be generated for each element type. This is done with a parsing word:"
{ $subsection POSTPONE: SPECIALIZED-ARRAY: }
"This parsing word adds new words to the search path:"
{ $subsection "specialized-array-words" }
{ $subsection "specialized-array-c" }
{ $subsection "specialized-array-math" }
{ $subsection "specialized-array-examples" }
"The " { $vocab-link "specialized-vectors" } " vocabulary provides a resizable version of this abstraction." ;

ABOUT: "specialized-arrays"
