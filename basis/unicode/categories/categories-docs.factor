! Copyright (C) 2009 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax kernel ;
IN: unicode.categories

HELP: LETTER
{ $class-description "The class of upper cased letters." } ;

HELP: Letter
{ $class-description "The class of letters." } ;

HELP: alpha
{ $class-description "The class of alphanumeric characters." } ;

HELP: math
{ $class-description "The class of Unicode math characters." } ;

HELP: blank
{ $class-description "The class of whitespace characters." } ;

HELP: character
{ $class-description "The class of pre-defined Unicode code points." } ;

HELP: control
{ $class-description "The class of control characters." } ;

HELP: digit
{ $class-description "The class of digits." } ;

HELP: letter
{ $class-description "The class of lower-cased letters." } ;

HELP: printable
{ $class-description "The class of characters which are printable, as opposed to being control or formatting characters." } ;

HELP: uncased
{ $class-description "The class of letters which don't have a case." } ;

ARTICLE: "unicode.categories" "Character classes"
"The " { $vocab-link "unicode.categories" } " vocabulary implements predicates for determining if a code point has a particular property, for example being a lower cased letter. These should be used in preference to the " { $vocab-link "ascii" } " equivalents in most cases. Each character class has an associated predicate word."
{ $subsections
    blank
    blank?
    letter
    letter?
    LETTER
    LETTER?
    Letter
    Letter?
    digit
    digit?
    printable
    printable?
    alpha
    alpha?
    control
    control?
    uncased
    uncased?
    character
    character?
    math
    math?
} ;

ABOUT: "unicode.categories"
