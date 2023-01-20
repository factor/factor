! Copyright (C) 2009 Jason W. Merrill.
! See https://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax kernel math
math.derivatives.syntax words ;
IN: math.dual

HELP: <dual>
{ $values
    { "ordinary-part" real } { "epsilon-part" real }
    { "dual" dual number }
}
{ $description "Creates a dual number from its ordinary and epsilon parts." } ;

HELP: define-dual
{ $values
    { "word" word }
}
{ $description "Defines a word " { $snippet "d[word]" } " in the " { $vocab-link "math.dual" } " vocabulary that operates on dual numbers." }
{ $notes "Uses the derivative word-prop, which holds a list of quotations giving the partial derivatives of the word with respect to each of its arguments. This can be set using " { $link POSTPONE: DERIVATIVE: } "." } ;

{ define-dual dual-op POSTPONE: DERIVATIVE: } related-words

HELP: dual
{ $class-description "The class of dual numbers with non-zero epsilon part." } ;

HELP: dual-op
{ $values
    { "word" word }
}
{ $description "Similar to " { $link execute } ", but promotes word to operate on duals." }
{ $notes "Uses the derivative word-prop, which holds a list of quotations giving the partial derivatives of the word with respect to each of its arguments. This can be set using " { $link POSTPONE: DERIVATIVE: } ". Once a derivative has been defined for a word, dual-op makes it easy to extend the definition to dual numbers." }
{ $examples
    { $unchecked-example "USING: math math.dual math.derivatives.syntax math.functions ;"
    "DERIVATIVE: sin [ cos * ]"
    "M: dual sin \\sin dual-op ;" "" }
    { $unchecked-example "USING: math math.dual math.derivatives.syntax ;"
    "DERIVATIVE: * [ drop ] [ nip ]"
    ": d* ( x y -- x*y ) \ * dual-op ;" "" }
} ;

HELP: unpack-dual
{ $values
    { "dual" dual }
    { "ordinary-part" number } { "epsilon-part" number }
}
{ $description "Extracts the ordinary and epsilon part of a dual number." } ;

ARTICLE: "math.dual" "Dual Numbers"
"The " { $vocab-link "math.dual" } " vocabulary implements dual numbers, along with arithmetic methods for working with them. Many of the functions in " { $vocab-link "math.functions" } " are extended to work with dual numbers."
$nl
"Dual numbers are ordered pairs " { $snippet "<o,e>" } "--an ordinary part and an epsilon part--with component-wise addition and multiplication defined by " { $snippet "<o1,e1>*<o2,e2> = <o1*o2,e1*o2 + e2*o1>" } ". They are analagous to complex numbers with " { $snippet "i^2 = 0" } "instead of " { $snippet "i^2 = -1" } ". For well-behaved functions " { $snippet "f" } ", " { $snippet "f(<o1,e1>) = f(o1) + e1*f'(o1)" } ", where " { $snippet "f'" } " is the derivative of " { $snippet "f" } "."
;

ABOUT: "math.dual"
