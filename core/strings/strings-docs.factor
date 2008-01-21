USING: arrays byte-arrays bit-arrays help.markup help.syntax
kernel kernel.private strings.private sequences vectors
sbufs math ;
IN: strings

ARTICLE: "strings" "Strings"
"A string is a fixed-size mutable sequence of characters. The literal syntax is covered in " { $link "syntax-strings" } "."
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
"Characters are not a first-class type; they are simply represented as integers between 0 and 65535. A few words operate on characters:"
{ $subsection blank? }
{ $subsection letter? }
{ $subsection LETTER? }
{ $subsection digit? }
{ $subsection printable? }
{ $subsection control? }
{ $subsection quotable? }
{ $subsection ch>lower }
{ $subsection ch>upper } ;

ABOUT: "strings"

HELP: string
{ $description "The class of fixed-length character strings. See " { $link "syntax-strings" } " for syntax and " { $link "strings" } " for general information." } ;

HELP: char-slot ( n string -- ch )
{ $values { "n" fixnum } { "string" string } { "ch" "the character at the " { $snippet "n" } "th index" } }
{ $description "Unsafe string accessor, used to define " { $link nth } " on strings." }
{ $warning "This word is in the " { $vocab-link "strings.private" } " vocabulary because it does not perform type or bounds checking. User code should call " { $link nth } " instead." } ;

HELP: set-char-slot ( ch n string -- )
{ $values { "ch" "a character" } { "n" fixnum } { "string" string }  }
{ $description "Unsafe string mutator, used to define " { $link set-nth } " on strings." }
{ $warning "This word is in the " { $vocab-link "strings.private" } " vocabulary because it does not perform type or bounds checking. User code should call " { $link set-nth } " instead." } ;

HELP: <string> ( n ch -- string )
{ $values { "n" "a positive integer specifying string length" } { "ch" "an initial character" } { "string" string } }
{ $description "Creates a new string with the given length and all characters initially set to " { $snippet "ch" } "." } ;

HELP: blank?
{ $values { "ch" "a character" } { "?" "a boolean" } }
{ $description "Tests for an ASCII whitespace character." } ;

HELP: letter?
{ $values { "ch" "a character" } { "?" "a boolean" } }
{ $description "Tests for a lowercase alphabet ASCII character." } ;

HELP: LETTER?
{ $values { "ch" "a character" } { "?" "a boolean" } }
{ $description "Tests for a uppercase alphabet ASCII character." } ;

HELP: digit?
{ $values { "ch" "a character" } { "?" "a boolean" } }
{ $description "Tests for an ASCII decimal digit character." } ;

HELP: Letter?
{ $values { "ch" "a character" } { "?" "a boolean" } }
{ $description "Tests for an ASCII alphabet character, both upper and lower case." } ;

HELP: alpha?
{ $values { "ch" "a character" } { "?" "a boolean" } }
{ $description "Tests for an alphanumeric ASCII character." } ;

HELP: printable?
{ $values { "ch" "a character" } { "?" "a boolean" } }
{ $description "Tests for a printable ASCII character." } ;

HELP: control?
{ $values { "ch" "a character" } { "?" "a boolean" } }
{ $description "Tests for an ASCII control character." } ;

HELP: quotable?
{ $values { "ch" "a character" } { "?" "a boolean" } }
{ $description "Tests for characters which may appear in a Factor string literal without escaping." } ;

HELP: ch>lower
{ $values { "ch" "a character" } { "lower" "a character" } }
{ $description "Converts a character to lowercase." } ;

HELP: ch>upper
{ $values { "ch" "a character" } { "upper" "a character" } }
{ $description "Converts a character to uppercase." } ;

HELP: >lower
{ $values { "str" string } { "lower" string } }
{ $description "Converts a string to lowercase." } ;

HELP: >upper
{ $values { "str" string } { "upper" string } }
{ $description "Converts a string to uppercase." } ;

HELP: 1string
{ $values { "ch" "a character"} { "str" string } }
{ $description "Outputs a string of one character." } ;

HELP: >string
{ $values { "seq" "a sequence of characters" } { "str" string } }
{ $description "Outputs a freshly-allocated string with the same elements as a given sequence." }
{ $errors "Throws an error if the sequence contains elements other than real numbers." } ;

HELP: resize-string ( n str -- newstr )
{ $values { "n" "a non-negative integer" } { "str" string } { "newstr" string } }
{ $description "Creates a new string " { $snippet "n" } " characters long The contents of the existing string are copied into the new string; if the new string is shorter, only an initial segment is copied, and if the new string is longer the remaining space is filled with " { $snippet "\\u0000" } "." } ;
