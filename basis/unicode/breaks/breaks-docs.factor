USING: help.syntax help.markup strings ;
IN: unicode.breaks

ABOUT: "unicode.breaks"

ARTICLE: "unicode.breaks" "Word and grapheme breaks"
"The " { $vocab-link "unicode.breaks" "unicode.breaks" } " vocabulary partially implements Unicode Standard Annex #29. This provides for segmentation of a string along grapheme and word boundaries. In Unicode, a grapheme, or a basic unit of display in text, may be more than one code point. For example, in the string \"e\\u000301\" (where U+0301 is a combining acute accent), there is only one grapheme, as the acute accent goes above the e, forming a single grapheme. Word breaks, in general, are more complicated than simply splitting by whitespace, and the Unicode algorithm provides for that."
$nl "Operations for graphemes:"
{ $subsection first-grapheme }
{ $subsection first-grapheme-from }
{ $subsection last-grapheme }
{ $subsection last-grapheme-from }
{ $subsection >graphemes }
{ $subsection string-reverse }
"Operations on words:"
{ $subsection first-word }
{ $subsection first-word-from }
{ $subsection last-word }
{ $subsection last-word-from }
{ $subsection >words } ;

HELP: first-grapheme
{ $values { "str" string } { "i" "an index" } }
{ $description "Finds the length of the first grapheme of the string. This can be used repeatedly to efficiently traverse the graphemes of the string, using slices." } ;

HELP: last-grapheme
{ $values { "str" string } { "i" "an index" } }
{ $description "Finds the index of the start of the last grapheme of the string. This can be used to traverse the graphemes of a string backwards." } ;

HELP: first-grapheme-from
{ $values { "start" "an index" } { "str" string } { "i" "an index" } }
{ $description "Finds the length of the first grapheme of the string, starting from the given index. This can be used repeatedly to efficiently traverse the graphemes of the string, using slices." } ;

HELP: last-grapheme-from
{ $values { "end" "an index" } { "str" string } { "i" "an index" } }
{ $description "Finds the index of the start of the last grapheme of the string, starting from the given index. This can be used to traverse the graphemes of a string backwards." } ;

HELP: >graphemes
{ $values { "str" string } { "graphemes" "an array of strings" } }
{ $description "Divides a string into a sequence of individual graphemes." } ;

HELP: string-reverse
{ $values { "str" string } { "rts" string } }
{ $description "Reverses a string, leaving graphemes in-tact." } ;

HELP: first-word
{ $values { "str" string } { "i" "index" } }
{ $description "Finds the index of the end of the first word in the string." } ;

HELP: last-word
{ $values { "str" string } { "i" "index" } }
{ $description "Finds the index of the beginning of the last word in the string." } ;

HELP: first-word-from
{ $values { "start" "index" } { "str" string } { "i" "index" } }
{ $description "Finds the index of the end of the first word in the string, starting from the given index." } ;

HELP: last-word-from
{ $values { "end" "index" } { "str" string } { "i" "index" } }
{ $description "Finds the index of the start of the word that the index is contained in." } ;

HELP: >words
{ $values { "str" string } { "words" "an array of strings" } }
{ $description "Divides the string up into words." } ;
