! Copyright (C) 2010 Erik Charlebois.
! See https://factorcode.org/license.txt for BSD license.
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
{ $description "Convert a number to an enum. If multiple members have the same value, returns the first declared member. Numbers with no matching member are returned unchanged. Compiled conversions track changes to the enum boxer generator and rebuild their expansions when it is redefined." } ;

{ POSTPONE: ENUM: define-enum enum>number number>enum } related-words

ABOUT: "alien.enums"
