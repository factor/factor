USING: arrays byte-arrays help.markup help.syntax
kernel kernel.private strings.private sequences vectors
sbufs math help.vocabs ;
IN: strings

ARTICLE: "strings" "Strings"
"The " { $vocab-link "strings" } " vocabulary implements a data type for storing text. Strings are represented as fixed-size mutable sequences of Unicode code points. Code points are represented as integers in the range [0,2,097,152]."
$nl
"Strings implement the " { $link "sequence-protocol" } ", and basic string manipulation can be performed with " { $link "sequences" } " from the " { $vocab-link "sequences" } " vocabulary. More text processing functionality can be found in vocabularies carrying the " { $link T{ vocab-tag { name "text" } } } " tag."
$nl
"Strings form a class:"
{ $subsections
    string
    string?
}
"Creating new strings:"
{ $subsections
    >string
    <string>
}
"Creating a string from a single character:"
{ $subsections 1string }
{ $see-also "syntax-strings" "sbufs" "unicode" "io.encodings" } ;

ABOUT: "strings"

HELP: string
{ $description "The class of fixed-length character strings. See " { $link "syntax-strings" } " for syntax and " { $link "strings" } " for general information." } ;

HELP: string-nth
{ $values { "n" fixnum } { "string" string } { "ch" "the character at the " { $snippet "n" } "th index" } }
{ $description "Unsafe string accessor, used to define " { $link nth } " on strings." }
{ $warning "This word is in the " { $vocab-link "strings.private" } " vocabulary because it does not perform type or bounds checking. User code should call " { $link nth } " instead." } ;

HELP: set-string-nth
{ $values { "ch" "a character" } { "n" fixnum } { "string" string }  }
{ $description "Unsafe string mutator, used to define " { $link set-nth } " on strings." }
{ $warning "This word is in the " { $vocab-link "strings.private" } " vocabulary because it does not perform type or bounds checking. User code should call " { $link set-nth } " instead." } ;

HELP: <string>
{ $values { "n" "a positive integer specifying string length" } { "ch" "an initial character" } { "string" string } }
{ $description "Creates a new string with the given length and all characters initially set to " { $snippet "ch" } "." } ;

HELP: 1string
{ $values { "ch" "a character"} { "str" string } }
{ $description "Outputs a string of one character." } ;

HELP: >string
{ $values { "seq" "a sequence of characters" } { "str" string } }
{ $description "Outputs a freshly-allocated string with the same elements as a given sequence, by interpreting the sequence elements as Unicode code points." }
{ $notes "This operation is only appropriate if the underlying sequence holds Unicode code points, which is rare unless it is a " { $link slice } " of another string. To convert a sequence of bytes to a string, use the words documented in " { $link "io.encodings.string" } "." }
{ $errors "Throws an error if the sequence contains elements other than integers." } ;

HELP: resize-string ( n str -- newstr )
{ $values { "n" "a non-negative integer" } { "str" string } { "newstr" string } }
{ $description "Creates a new string " { $snippet "n" } " characters long The contents of the existing string are copied into the new string; if the new string is shorter, only an initial segment is copied, and if the new string is longer the remaining space is filled with " { $snippet "\\u000000" } "." } ;
