! Copyright (C) 2017 Alexander Ilin.
! See https://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax kernel ;
IN: classes.maybe

ABOUT: "maybes"

ARTICLE: "maybes" "Maybe classes"
"A " { $snippet "maybe" } " is an anonymous union class (" { $link "unions" } ") of its members and the " { $link POSTPONE: f } " class. An object is an instance of a " { $snippet "maybe" } " class if it is either an instance of any of its participants, or " { $link POSTPONE: f } "." $nl
"The " { $snippet "maybe" } " classes are used to declare typed slots that are optional for a tuple. Without this mechanism it would be an error to assign " { $link POSTPONE: f } " to such a typed slot, and therefore any tuple containing them without specifying an " { $link POSTPONE: initial: } " value could not be created with the word " { $link new } "." $nl
"A slot with an empty " { $snippet "maybe{ }" } " class can only hold the " { $link POSTPONE: f } " value."
{ $examples
    { $example
        "USING: prettyprint ;"
        "TUPLE: test-maybe { value maybe{ fixnum string } } ;"
        "test-maybe new value>> ."
        "f"
    }
}
{ $see-also "unions" POSTPONE: maybe{ } ;
