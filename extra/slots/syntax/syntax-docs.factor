! Copyright (C) 2010 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax ;
IN: slots.syntax

HELP: slots[
{ $description "Outputs several slot values to the stack." }
{ $example "USING: kernel prettyprint slots.syntax ;"
           "IN: slots.syntax.example"
           "TUPLE: rectangle width height ;"
           "T{ rectangle { width 3 } { height 5 } } slots[ width height ] [ . ] bi@"
           """3
5"""
} ;

HELP: slots{
{ $description "Outputs an array of slot values from a tuple." }
{ $example "USING: prettyprint slots.syntax ;"
           "IN: slots.syntax.example"
           "TUPLE: rectangle width height ;"
           "T{ rectangle { width 3 } { height 5 } } slots{ width height } ."
           "{ 3 5 }"
} ;

ARTICLE: "slots.syntax" "Slots syntax sugar"
"The " { $vocab-link "slots.syntax" } " vocabulary provides an alternative syntax for taking a sequence of slots from a tuple." $nl
"Syntax sugar for cleaving slots to the stack:"
{ $subsections POSTPONE: slots[ }
"Syntax sugar for cleaving slots to an array:"
{ $subsections POSTPONE: slots{ } ;

ABOUT: "slots.syntax"
