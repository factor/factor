USING: help.markup help.syntax ;
IN: ascii

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

ARTICLE: "ascii" "ASCII character classes"
"Traditional ASCII character classes:"
{ $subsection blank? }
{ $subsection letter? }
{ $subsection LETTER? }
{ $subsection digit? }
{ $subsection printable? }
{ $subsection control? }
{ $subsection quotable? }
"Modern applications should use Unicode 5.0 instead (" { $vocab-link "unicode" } ")." ;

ABOUT: "ascii"
