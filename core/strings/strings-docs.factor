USING: arrays byte-arrays help.markup help.syntax
kernel kernel.private strings.private sequences vectors
sbufs math ;
IN: strings

ARTICLE: "strings" "Strings"
"A string is a fixed-size mutable sequence of Unicode 5.0 code points."
$nl
"Characters are not a first-class type; they are simply represented as integers between 0 and 16777216 (2^24). Only characters up to 2097152 (2^21) have a defined meaning in Unicode."
$nl
"String literal syntax is covered in " { $link "syntax-strings" } "."
$nl
"String words are found in the " { $vocab-link "strings" } " vocabulary."
$nl
"Strings form a class:"
{ $subsection string }
{ $subsection string? }
"Creating strings:"
{ $subsection >string }
{ $subsection <string> }
"Creating a string from a single character:"
{ $subsection 1string }
"Since strings are sequences, basic string manipulation can be performed using sequence operations (" { $link "sequences" } "). More advanced functionality can be found in other vocabularies, including but not limited to:"
{ $list
    { { $link "ascii" } " - ASCII algorithms for interoperability with legacy applications" }
    { { $link "unicode" } " - Unicode algorithms for modern multilingual applications" }
    { { $vocab-link "regexp" } " - regular expressions" }
    { { $vocab-link "peg" } " - parser expression grammars" }
} ;

ABOUT: "strings"

HELP: string
{ $description "The class of fixed-length character strings. See " { $link "syntax-strings" } " for syntax and " { $link "strings" } " for general information." } ;

HELP: string-nth ( n string -- ch )
{ $values { "n" fixnum } { "string" string } { "ch" "the character at the " { $snippet "n" } "th index" } }
{ $description "Unsafe string accessor, used to define " { $link nth } " on strings." }
{ $warning "This word is in the " { $vocab-link "strings.private" } " vocabulary because it does not perform type or bounds checking. User code should call " { $link nth } " instead." } ;

HELP: set-string-nth ( ch n string -- )
{ $values { "ch" "a character" } { "n" fixnum } { "string" string }  }
{ $description "Unsafe string mutator, used to define " { $link set-nth } " on strings." }
{ $warning "This word is in the " { $vocab-link "strings.private" } " vocabulary because it does not perform type or bounds checking. User code should call " { $link set-nth } " instead." } ;

HELP: <string> ( n ch -- string )
{ $values { "n" "a positive integer specifying string length" } { "ch" "an initial character" } { "string" string } }
{ $description "Creates a new string with the given length and all characters initially set to " { $snippet "ch" } "." } ;

HELP: 1string
{ $values { "ch" "a character"} { "str" string } }
{ $description "Outputs a string of one character." } ;

HELP: >string
{ $values { "seq" "a sequence of characters" } { "str" string } }
{ $description "Outputs a freshly-allocated string with the same elements as a given sequence." }
{ $errors "Throws an error if the sequence contains elements other than real numbers." } ;

HELP: resize-string ( n str -- newstr )
{ $values { "n" "a non-negative integer" } { "str" string } { "newstr" string } }
{ $description "Creates a new string " { $snippet "n" } " characters long The contents of the existing string are copied into the new string; if the new string is shorter, only an initial segment is copied, and if the new string is longer the remaining space is filled with " { $snippet "\\u000000" } "." } ;
