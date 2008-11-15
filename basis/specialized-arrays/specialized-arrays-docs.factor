USING: help.markup help.syntax byte-arrays ;
IN: specialized-arrays

ARTICLE: "specialized-arrays" "Specialized arrays"
"The " { $vocab-link "specialized-arrays" } " vocabulary implements fixed-length sequence types for storing machine values in a space-efficient manner without boxing."
$nl
"For each primitive C type " { $snippet "T" } ", a set of words are defined:"
{ $table
    { { $snippet "T-array" } { "The class of arrays with elements of type " { $snippet "T" } } }
    { { $snippet "<T-array>" } { "Constructor for arrays with elements of type " { $snippet "T" } "; stack effect " { $snippet "( len -- array )" } } }
    { { $snippet ">T-array" } { "Converts a sequence into a specialized array of type " { $snippet "T" } "; stack effect " { $snippet "( seq -- array )" } } }
    { { $snippet "T-array{" } { "Literal syntax, consists of a series of values terminated by " { $snippet "}" } } }
}
"Each specialized array has a " { $slot "underlying" } " slot holding a " { $link byte-array } " with the raw data. This data can be passed to C functions."
$nl
"The primitive C types for which specialized arrays exist:"
{ $list
    { $snippet "char" }
    { $snippet "uchar" }
    { $snippet "short" }
    { $snippet "ushort" }
    { $snippet "int" }
    { $snippet "uint" }
    { $snippet "long" }
    { $snippet "ulong" }
    { $snippet "longlong" }
    { $snippet "ulonglong" }
    { $snippet "float" }
    { $snippet "double" }
    { $snippet "void*" }
    { $snippet "bool" }
}
"Specialized arrays are generated with a functor in the " { $vocab-link "specialized-arrays.functor" } " vocabulary."
$nl
"The " { $vocab-link "specialized-vectors" } " vocabulary provides resizable versions of the above." ;

ABOUT: "specialized-arrays"
