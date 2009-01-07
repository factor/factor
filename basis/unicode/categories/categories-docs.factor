! Copyright (C) 2009 Your name.
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax kernel ;
IN: unicode.categories

HELP: LETTER?
{ $values { "ch" "a character" } { "?" "a boolean" } }
{ $description "Determines whether the code point is an upper-cased letter" } ;

HELP: Letter?
{ $values { "ch" "a character" } { "?" "a boolean" } }
{ $description "Determines whether the code point is a letter of any case" } ;

HELP: alpha?
{ $values { "ch" "a character" } { "?" "a boolean" } }
{ $description "Determines whether the code point is alphanumeric" } ;

HELP: blank?
{ $values { "ch" "a character" } { "?" "a boolean" } }
{ $description "Determines whether the code point is whitespace" } ;

HELP: character?
{ $values { "ch" "a character" } { "?" "a boolean" } }
{ $description "Determines whether a number is a code point which has been assigned" } ;

HELP: control?
{ $values { "ch" "a character" } { "?" "a boolean" } }
{ $description "Determines whether a code point is a control character" } ;

HELP: digit?
{ $values { "ch" "a character" } { "?" "a boolean" } }
{ $description "Determines whether a code point is a digit" } ;

HELP: letter?
{ $values { "ch" "a character" } { "?" "a boolean" } }
{ $description "Determines whether a code point is a lower-cased letter" } ;

HELP: printable?
{ $values { "ch" "a character" } { "?" "a boolean" } }
{ $description "Determines whether a code point is printable, as opposed to being a control character or formatting character" } ;

HELP: uncased?
{ $values { "ch" "a character" } { "?" "a boolean" } }
{ $description "Determines whether a character has a case" } ;

ARTICLE: "unicode.categories" "Character classes"
{ $vocab-link "unicode.categories" } " is a vocabulary which provides predicates for determining if a code point has a particular property, for example being a lower cased letter. These should be used in preference to the " { $vocab-link "ASCII" "ascii" } " equivalents in most cases. Below are links to the useful predicates, but note that each of these is defined to be a predicate class."
{ $subsection blank? }
{ $subsection letter? }
{ $subsection LETTER? }
{ $subsection Letter? }
{ $subsection digit? }
{ $subsection printable? }
{ $subsection alpha? }
{ $subsection control? }
{ $subsection uncased? }
{ $subsection character? } ;

ABOUT: "unicode.categories"
