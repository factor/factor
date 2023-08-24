! Copyright (C) 2009 Jason W. Merrill.
! See https://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax ;
IN: math.derivatives.syntax

HELP: DERIVATIVE:
{ $description "Defines the derivative of a word by setting its " { $snippet "derivative" } " word property. Reads a word followed by " { $snippet "n" } " quotations, giving the " { $snippet "n" } " partial derivatives of the word with respect to each of its arguments successively. Each quotation should take " { $snippet "n + 1" } " inputs, where the first input is an increment and the last " { $snippet "n" } " inputs are the point at which to evaluate the derivative. The derivative should be a linear function of the increment, and should have the same number of outputs as the original word." }
{ $examples
    { $unchecked-example "USING: math math.functions math.derivatives.syntax ;"
    "DERIVATIVE: sin [ cos * ]"
    "DERIVATIVE: * [ nip * ] [ drop * ]" "" }
} ;

ARTICLE: "math.derivatives.syntax" "Derivative Syntax"
"The " { $vocab-link "math.derivatives.syntax" } " vocabulary provides the " { $link POSTPONE: DERIVATIVE: } " syntax for specifying the derivative of a word."
;

ABOUT: "math.derivatives.syntax"
