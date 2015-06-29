USING: help.markup help.syntax kernel strings ;
IN: ascii

HELP: blank?
{ $values { "ch" "a character" } { "?" boolean } }
{ $description "Tests for an ASCII whitespace character." } ;

HELP: letter?
{ $values { "ch" "a character" } { "?" boolean } }
{ $description "Tests for a lowercase alphabet ASCII character." } ;

HELP: LETTER?
{ $values { "ch" "a character" } { "?" boolean } }
{ $description "Tests for a uppercase alphabet ASCII character." } ;

HELP: digit?
{ $values { "ch" "a character" } { "?" boolean } }
{ $description "Tests for an ASCII decimal digit character." } ;

HELP: Letter?
{ $values { "ch" "a character" } { "?" boolean } }
{ $description "Tests for an ASCII alphabet character, both upper and lower case." } ;

HELP: alpha?
{ $values { "ch" "a character" } { "?" boolean } }
{ $description "Tests for an alphanumeric ASCII character." } ;

HELP: printable?
{ $values { "ch" "a character" } { "?" boolean } }
{ $description "Tests for a printable ASCII character." } ;

HELP: control?
{ $values { "ch" "a character" } { "?" boolean } }
{ $description "Tests for an ASCII control character." } ;

HELP: quotable?
{ $values { "ch" "a character" } { "?" boolean } }
{ $description "Tests for characters which may appear in a Factor string literal without escaping." } ;

HELP: ascii?
{ $values { "ch" "a character" } { "?" boolean } }
{ $description "Tests for whether a number is an ASCII character." } ;

HELP: ch>lower
{ $values { "ch" "a character" } { "lower" "a character" } }
{ $description "Converts an ASCII character to lower case." } ;

HELP: ch>upper
{ $values { "ch" "a character" } { "upper" "a character" } }
{ $description "Converts an ASCII character to upper case." } ;

HELP: >lower
{ $values { "str" string } { "lower" string } }
{ $description "Converts an ASCII string to lower case." } ;

HELP: >upper
{ $values { "str" string } { "upper" string } }
{ $description "Converts an ASCII string to upper case." } ;

HELP: >title
{ $values { "str" string } { "title" string } }
{ $description "Converts a string to title case." } ;

HELP: >words
{ $values { "str" string } { "words" "an array of slices" } }
{ $description "Divides the string up into words." } ;

HELP: capitalize
{ $values { "str" string } { "str'" string } }
{ $description "Capitalize all the words in a string." } ;

ARTICLE: "ascii" "ASCII"
"The " { $vocab-link "ascii" } " vocabulary implements support for the legacy ASCII character set. Most applications should use " { $link "unicode" } " instead."
$nl
"ASCII character classes:"
{ $subsections
    blank?
    letter?
    LETTER?
    digit?
    printable?
    control?
    quotable?
    ascii?
}
"ASCII case conversion:"
{ $subsections
    ch>lower
    ch>upper
    >lower
    >upper
    >title
} ;

ABOUT: "ascii"
