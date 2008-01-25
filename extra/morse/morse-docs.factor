! Copyright (C) 2007 Alex Chapman
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax morse ;

HELP: ch>morse
{ $values
    { "ch" "A character that has a morse code translation" } { "str" "A string consisting of zero or more dots and dashes" } }
{ $description "If the given character has a morse code translation, then return that translation, otherwise return an empty string." } ;

HELP: morse>ch
{ $values
    { "str" "A string of dots and dashes that represents a single character in morse code" } { "ch" "The translated character" } }
{ $description "If the given string represents a morse code character, then return that character, otherwise return f" } ;
