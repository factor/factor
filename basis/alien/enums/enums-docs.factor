! Copyright (C) 2010 Erik Charlebois.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.syntax help.markup help.syntax words ;
IN: alien.enums

HELP: define-enum
{ $values
    { "word" word } { "base-type" c-type } { "members" "sequence of word and value pairs" }
}
{ $description "Defines an enum. This is the run-time equivalent of " { $link POSTPONE: ENUM: } "." } ;

HELP: enum>number
{ $values
    { "enum" "an enum word" }
    { "number" "the corresponding number value" }
}
{ $description "Converts an enum to a number." } ;

HELP: number>enum
{ $values
    { "number" "an enum number" } { "enum-c-type" "an enum type" }
    { "enum" "the corresponding enum word" }
}
{ $description "Convert a number to an enum." } ;

ARTICLE: "alien.enums" "Enumeration types"
"The " { $vocab-link "alien.enums" } " vocab contains the implementation for " { $link POSTPONE: ENUM: } " C types, and provides words for converting between enum singletons and integers. It is possible to dispatch off of members of an enum."
$nl
"Defining enums at run-time:"
{ $subsection define-enum }
"Conversions between enums and integers:"
{ $subsections enum>number number>enum } ;

{ POSTPONE: ENUM: define-enum enum>number number>enum } related-words

ABOUT: "alien.enums"
