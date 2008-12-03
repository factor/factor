USING: help.markup help.syntax byte-vectors ;
IN: specialized-vectors

ARTICLE: "specialized-vectors" "Specialized vectors"
"The " { $vocab-link "specialized-vectors" } " vocabulary implements resizable sequence types for storing machine values in a space-efficient manner without boxing."
$nl
"For each primitive C type " { $snippet "T" } ", a set of words are defined:"
{ $table
    { { $snippet "T-vector" } { "The class of vectors with elements of type " { $snippet "T" } } }
    { { $snippet "<T-vector>" } { "Constructor for vectors with elements of type " { $snippet "T" } "; stack effect " { $snippet "( len -- vector )" } } }
    { { $snippet ">T-vector" } { "Converts a sequence into a specialized vector of type " { $snippet "T" } "; stack effect " { $snippet "( seq -- vector )" } } }
    { { $snippet "T-vector{" } { "Literal syntax, consists of a series of values terminated by " { $snippet "}" } } }
}
"The primitive C types for which specialized vectors exist:"
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
"Specialized vectors are generated with a functor in the " { $vocab-link "specialized-vectors.functor" } " vocabulary."
$nl
"The " { $vocab-link "specialized-arrays" } " vocabulary provides fixed-length versions of the above." ;

ABOUT: "specialized-vectors"
