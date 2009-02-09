! Copyright (C) 2009 Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax quotations effects words ;
IN: call

ABOUT: "call"

ARTICLE: "call" "Calling code with known stack effects"
"The " { $vocab-link "call" } " vocabulary allows for arbitrary quotations to be called from code accepted by the optimizing compiler. This is done by specifying the stack effect of the quotation literally. It is checked at runtime that the stack effect is accurate."
{ $subsection POSTPONE: call( }
{ $subsection POSTPONE: execute( }
{ $subsection call-effect }
{ $subsection execute-effect } ;

HELP: call(
{ $syntax "[ ] call( foo -- bar )" }
{ $description "Calls the quotation on the top of the stack, asserting that it has the given stack effect. The quotation does not need to be known at compile time." } ;

HELP: call-effect
{ $values { "quot" quotation } { "effect" effect } }
{ $description "Given a quotation and a stack effect, calls the quotation, asserting at runtime that it has the given stack effect. This is a macro which expands given a literal effect parameter, and an arbitrary quotation which is not required at compile time." } ;

HELP: execute(
{ $syntax "word execute( foo -- bar )" }
{ $description "Calls the word on the top of the stack, aserting that it has the given stack effect. The word does not need to be known at compile time." } ;

HELP: execute-effect
{ $values { "word" word } { "effect" effect } }
{ $description "Given a word and a stack effect, executes the word, asserting at runtime that it has the given stack effect. This is a macro which expands given a literal effect parameter, and an arbitrary word which is not required at compile time." } ;

{ execute-effect call-effect } related-words
{ POSTPONE: call( POSTPONE: execute( } related-words
