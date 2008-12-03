USING: help.markup help.syntax byte-arrays alien ;
IN: specialized-arrays.direct

ARTICLE: "specialized-arrays.direct" "Direct-mapped specialized arrays"
"The " { $vocab-link "specialized-arrays.direct" } " vocabulary implements fixed-length sequence types for storing machine values in unmanaged C memory."
$nl
"For each primitive C type " { $snippet "T" } ", a set of words are defined:"
{ $table
    { { $snippet "direct-T-array" } { "The class of direct arrays with elements of type " { $snippet "T" } } }
    { { $snippet "<direct-T-array>" } { "Constructor for arrays with elements of type " { $snippet "T" } "; stack effect " { $snippet "( alien len -- array )" } } }
}
"Each direct array has a " { $slot "underlying" } " slot holding an " { $link simple-alien } " pointer to the raw data. This data can be passed to C functions."
$nl
"The primitive C types for which direct arrays exist:"
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
"Direct arrays are generated with a functor in the " { $vocab-link "specialized-arrays.direct.functor" } " vocabulary." ;

ABOUT: "specialized-arrays.direct"
