USING: help.markup help.syntax ;
IN: sbufs

ARTICLE: "sbufs" "String buffers"
"The " { $vocab-link "sbufs" } " vocabulary implements resizable mutable sequence of characters. The literal syntax is covered in " { $link "syntax-sbufs" } "."
$nl
"String buffers implement the " { $link "sequence-protocol" } " and thus all " { $link "sequences" } " can be used with them. String buffers can be used to construct new strings by accumulating substrings and characters, however usually they are only used indirectly, since the sequence construction words are more convenient to use in most cases (see " { $link "namespaces-make" } ")."
$nl
"String buffers form a class of objects:"
{ $subsections
    sbuf
    sbuf?
}
"Words for creating string buffers:"
{ $subsections
    >sbuf
    <sbuf>
}
"If you don't care about initial capacity, a more elegant way to create a new string buffer is to write:"
{ $code "SBUF\" \" clone" } ;

ABOUT: "sbufs"

HELP: sbuf
{ $class-description "The class of resizable character strings. See " { $link "syntax-sbufs" } " for syntax and " { $link "sbufs" } " for general information." } ;

HELP: <sbuf>
{ $values { "n" "a positive integer specifying initial capacity" } { "sbuf" sbuf } }
{ $description "Creates a new string buffer that can hold " { $snippet "n" } " characters before resizing." } ;

HELP: >sbuf
{ $values { "seq" { $sequence "non-negative integers" } } { "sbuf" sbuf } }
{ $description "Outputs a freshly-allocated string buffer with the same elements as a given sequence." }
{ $errors "Throws an error if the sequence contains elements other than real numbers." } ;
