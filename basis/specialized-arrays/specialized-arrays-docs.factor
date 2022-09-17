USING: help.markup help.syntax byte-arrays alien math sequences ;
IN: specialized-arrays

HELP: SPECIALIZED-ARRAY:
{ $syntax "SPECIALIZED-ARRAY: type" }
{ $values { "type" "a C type" } }
{ $description "Brings a specialized array for holding values of " { $snippet "type" } " into the vocabulary search path. The generated words are documented in " { $link "specialized-array-words" } "." } ;

HELP: SPECIALIZED-ARRAYS:
{ $syntax "SPECIALIZED-ARRAYS: type type type ... ;" }
{ $values { "type" "a C type" } }
{ $description "Brings a set of specialized arrays for holding values of each " { $snippet "type" } " into the vocabulary search path. The generated words are documented in " { $link "specialized-array-words" } "." } ;

{ POSTPONE: SPECIALIZED-ARRAY: POSTPONE: SPECIALIZED-ARRAYS: } related-words

HELP: direct-slice
{ $values { "from" integer } { "to" integer } { "seq" "a specialized array" } { "seq'" "a new specialized array" } }
{ $description "Constructs a new specialized array of the same type as " { $snippet "seq" } " sharing the same underlying memory as the subsequence of " { $snippet "seq" } " from elements " { $snippet "from" } " up to but not including " { $snippet "to" } ". Like " { $link slice } ", raises an error if " { $snippet "from" } " or " { $snippet "to" } " is out of bounds." } ;

HELP: direct-head
{ $values { "seq" "a specialized array" } { "n" integer } { "seq'" "a new specialized array" } }
{ $description "Constructs a new specialized array of the same type as " { $snippet "seq" } " sharing the same underlying memory as the first " { $snippet "n" } " elements of " { $snippet "seq" } ". Like " { $link head } ", raises an error if " { $snippet "n" } " is out of bounds." } ;

HELP: direct-tail
{ $values { "seq" "a specialized array" } { "n" integer } { "seq'" "a new specialized array" } }
{ $description "Constructs a new specialized array of the same type as " { $snippet "seq" } " sharing the same underlying memory as " { $snippet "seq" } " without the first " { $snippet "n" } " elements. Like " { $link tail } ", raises an error if " { $snippet "n" } " is out of bounds." } ;

HELP: direct-head*
{ $values { "seq" "a specialized array" } { "n" integer } { "seq'" "a new specialized array" } }
{ $description "Constructs a new specialized array of the same type as " { $snippet "seq" } " sharing the same underlying memory as " { $snippet "seq" } " without the last " { $snippet "n" } " elements. Like " { $link head* } ", raises an error if " { $snippet "n" } " is out of bounds." } ;

HELP: direct-tail*
{ $values { "seq" "a specialized array" } { "n" integer } { "seq'" "a new specialized array" } }
{ $description "Constructs a new specialized array of the same type as " { $snippet "seq" } " sharing the same underlying memory as the last " { $snippet "n" } " elements of " { $snippet "seq" } ". Like " { $link tail* } ", raises an error if " { $snippet "n" } " is out of bounds." } ;

{ direct-slice direct-head direct-tail direct-head* direct-tail* } related-words

ARTICLE: "specialized-array-words" "Specialized array words"
"The " { $link POSTPONE: SPECIALIZED-ARRAY: } " and " { $link POSTPONE: SPECIALIZED-ARRAYS: } " parsing words generate specialized array types if they haven't been generated already and add the following words to the vocabulary search path, where " { $snippet "T" } " is the C type in question:"
{ $table
    { { $snippet "T-array" } { "The class of arrays with elements of type " { $snippet "T" } } }
    { { $snippet "<T-array>" } { "Constructor for arrays with elements of type " { $snippet "T" } "; stack effect " { $snippet "( len -- array )" } } }
    { { $snippet "(T-array)" } { "Constructor for arrays with elements of type " { $snippet "T" } ", where the initial contents are uninitialized; stack effect " { $snippet "( len -- array )" } } }
    { { $snippet "<direct-T-array>" } { "Constructor for arrays with elements of type " { $snippet "T" } " backed by raw memory; stack effect " { $snippet "( alien len -- array )" } } }
    { { $snippet "T-array{" } { "Literal syntax, consists of a series of values terminated by " { $snippet "}" } } }
}
"Behind the scenes, these words are placed in a vocabulary named " { $snippet "specialized-arrays.instances.T" } ", however this vocabulary should not be placed in a " { $link POSTPONE: USING: } " form directly. Instead, always use " { $link POSTPONE: SPECIALIZED-ARRAY: } " or " { $link POSTPONE: SPECIALIZED-ARRAYS: } ". This ensures that the vocabulary can get generated the first time it is needed."
$nl
"Additionally, special versions of the standard " { $link <slice> } ", " { $link head } ", and " { $link tail } " sequence operations are provided for specialized arrays to create a new specialized array object sharing storage with a subsequence of an existing array:"
{ $subsections
    direct-slice
    direct-head
    direct-tail
    direct-head*
    direct-tail*
} ;

ARTICLE: "specialized-array-c" "Passing specialized arrays to C functions"
"If a C function is declared as taking a parameter with a pointer or an array type (for example, " { $snippet "float*" } " or " { $snippet "int[3]" } "), instances of the relevant specialized array can be passed in."
$nl
"C type specifiers for array types are documented in " { $link "c-types-specs" } "."
$nl
"Here is an example; as is common with C functions, the array length is passed in separately, since C does not offer a runtime facility to determine the array length of a base pointer:"
{ $code
    "USING: alien.syntax specialized-arrays ;"
    "SPECIALIZED-ARRAY: int"
    "FUNCTION: void process_data ( int* data, int len )"
    "int-array{ 10 20 30 } dup length process_data"
}
"Literal specialized arrays, as well as specialized arrays created with " { $snippet "<T-array>" } " and " { $snippet "T >c-array" } " are backed by a " { $link byte-array } " in the Factor heap, and can move as a result of garbage collection. If this is unsuitable, the array can be allocated in unmanaged memory instead."
$nl
"In the following example, it is presumed that the C library holds on to a pointer to the array's data after the " { $snippet "init_with_data()" } " call returns; this is one situation where unmanaged memory has to be used instead. Note the use of destructors to ensure the memory is deallocated after the block ends:"
{ $code
    "USING: alien.syntax specialized-arrays ;"
    "SPECIALIZED-ARRAY: float"
    "FUNCTION: void init_with_data ( float* data, int len )"
    "FUNCTION: float compute_result ( )"
    "["
    "    100 malloc-float-array &free"
    "    dup length init_with_data"
    "    compute_result"
    "] with-destructors"
}
"Finally, sometimes a C library returns a pointer to an array in unmanaged memory, together with a length. In this case, a specialized array can be constructed to view this memory using " { $snippet "<direct-T-array>" } ":"
{ $code
    "USING: alien.c-types alien.data classes.struct ;"
    ""
    "STRUCT: device_info"
    "    { id int }"
    "    { name char* } ;"
    ""
    "FUNCTION: void get_device_info ( int* length )"
    ""
    "0 int <ref> [ get_device_info ] keep <direct-int-array> ."
}
"For a full discussion of Factor heap allocation versus unmanaged memory allocation, see " { $link "byte-arrays-gc" } "."
$nl
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
    "1000 <iota> [ 1000 /f pi * sin ] float-array{ } map-as"
    "0.0 [ + ] reduce ."
} ;

ARTICLE: "specialized-arrays" "Specialized arrays"
"The " { $vocab-link "specialized-arrays" } " vocabulary implements fixed-length sequence types for storing machine values in a space-efficient manner without boxing."
$nl
"A specialized array type needs to be generated for each element type. This is done with parsing words:"
{ $subsections
    POSTPONE: SPECIALIZED-ARRAY:
    POSTPONE: SPECIALIZED-ARRAYS:
}
"This parsing word adds new words to the search path, documented in the next section."
{ $subsections
    "specialized-array-words"
    "specialized-array-c"
    "specialized-array-math"
    "specialized-array-examples"
}
"The " { $vocab-link "specialized-vectors" } " vocabulary provides a resizable version of this abstraction." ;

ABOUT: "specialized-arrays"
