! Copyright (C) 2009 Your name.
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax kernel ;
IN: unicode.categories

HELP: LETTER
{ $class-description "The class of upper cased letters" } ;

HELP: Letter
{ $class-description "The class of letters" } ;

HELP: alpha
{ $class-description "The class of code points which are alphanumeric" } ;

HELP: blank
{ $class-description "The class of code points which are whitespace" } ;

HELP: character
{ $class-description "The class of numbers which are pre-defined Unicode code points" } ;

HELP: control
{ $class-description "The class of control characters" } ;

HELP: digit
{ $class-description "The class of code coints which are digits" } ;

HELP: letter
{ $class-description "The class of code points which are lower-cased letters" } ;

HELP: printable
{ $class-description "The class of characters which are printable, as opposed to being control or formatting characters" } ;

HELP: uncased
{ $class-description "The class of letters which don't have a case" } ;

ARTICLE: "unicode.categories" "Character classes"
{ $vocab-link "unicode.categories" } " is a vocabulary which provides predicates for determining if a code point has a particular property, for example being a lower cased letter. These should be used in preference to the " { $vocab-link "ascii" } " equivalents in most cases. Below are links to classes of characters, but note that each of these also has a predicate defined, which is usually more useful."
{ $subsection blank }
{ $subsection letter }
{ $subsection LETTER }
{ $subsection Letter }
{ $subsection digit }
{ $subsection printable }
{ $subsection alpha }
{ $subsection control }
{ $subsection uncased }
{ $subsection character } ;

ABOUT: "unicode.categories"
