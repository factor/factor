USING: kernel help.markup help.syntax sequences ;
IN: byte-arrays

ARTICLE: "byte-arrays" "Byte arrays"
"Byte arrays are fixed-size mutable sequences (" { $link "sequence-protocol" } ") whose elements are integers in the range 0-255, inclusive. Each element only uses one byte of storage, hence the name. The literal syntax is covered in " { $link "syntax-byte-arrays" } "."
$nl
"Byte array words are in the " { $vocab-link "byte-arrays" } " vocabulary."
$nl
"Byte arrays play a special role in the C library interface; they can be used to pass binary data back and forth between Factor and C. See " { $link "c-pointers" } "."
$nl
"Byte arrays form a class of objects."
{ $subsections
    byte-array
    byte-array?
}
"There are several ways to construct byte arrays."
{ $subsections
    >byte-array
    <byte-array>
    1byte-array
    2byte-array
    3byte-array
    4byte-array
}
"Resizing byte arrays:"
{ $subsections resize-byte-array } ;

ABOUT: "byte-arrays"

HELP: byte-array
{ $class-description "The class of byte arrays. See " { $link "syntax-byte-arrays" } " for syntax and " { $link "byte-arrays" } " for general information." } ;

HELP: <byte-array>
{ $values { "n" "a non-negative integer" } { "byte-array" byte-array } }
{ $examples { $example "USING: byte-arrays prettyprint ;" "3 <byte-array> ." "B{ 0 0 0 }" } }
{ $description "Creates a new " { $link byte-array } " of length " { $snippet "n" } " bytes, with the elements all initialized to zero." } ;

HELP: (byte-array)
{ $values { "n" "a non-negative integer" } { "byte-array" byte-array } }
{ $examples { $unchecked-example "USING: byte-arrays prettyprint ;" "3 (byte-array) ." "B{ 103 189 48 }" } }
{ $description "Creates a new " { $link byte-array } " of length " { $snippet "n" } " bytes, with the elements containing unspecified values." } ;

{ <byte-array> (byte-array) } related-words

HELP: >byte-array
{ $values { "seq" sequence } { "byte-array" byte-array } }
{ $description "Outputs a freshly-allocated byte array whose elements have the same signed byte values as a given sequence." }
{ $errors "Throws an error if the sequence contains elements other than integers." } ;

HELP: 1byte-array
{ $values
    { "x" object }
    { "byte-array" byte-array } }
{ $description "Creates a new byte-array with one element." } ;

HELP: 2byte-array
{ $values
    { "x" object } { "y" object }
    { "byte-array" byte-array } }
{ $description "Creates a new byte-array with two elements." } ;

HELP: 3byte-array
{ $values
    { "x" object } { "y" object } { "z" object }
    { "byte-array" byte-array } }
{ $description "Creates a new byte-array with three element." } ;

HELP: 4byte-array
{ $values
    { "w" object } { "x" object } { "y" object } { "z" object }
    { "byte-array" byte-array } }
{ $description "Creates a new byte-array with four elements." } ;

{ 1byte-array 2byte-array 3byte-array 4byte-array } related-words

HELP: resize-byte-array
{ $values { "n" "a non-negative integer" } { "byte-array" byte-array } { "new-byte-array" byte-array } }
{ $description "Resizes the byte array to have a length of " { $snippet "n" } " elements. When making the byte array shorter, this word may either create a new byte array or modify the existing byte array in place. When making the byte array longer, this word always allocates a new byte array, filling remaining space with zeroes." }
{ $side-effects "byte-array" } ;
