! Copyright (C) 2011 John Benediktsson.
! See https://factorcode.org/license.txt for BSD license.

USING: help.markup help.syntax successor strings ;

IN: successor

HELP: successor
{ $values { "str" string } { "str'" string } }
{ $description
    "Returns the successor to " { $snippet "str" } ". The successor is calculated by incrementing characters starting from the rightmost alphanumeric (or the rightmost character if there are no alphanumerics) in the string. Incrementing a digit always results in another digit, and incrementing a letter results in another letter of the same case."
    $nl
    "If the increment generates a carry, the character to the left of it is incremented. This process repeats until there is no carry, adding an additional character if necessary."
} ;


