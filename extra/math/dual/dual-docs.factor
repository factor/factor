! Copyright (C) 2009 Jason W. Merrill.
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax kernel words math math.functions math.derivatives.syntax ;
IN: math.dual

HELP: <dual>
{ $values
    { "ordinary-part" real } { "epsilon-part" real }
    { "dual" dual number }
}
{ $description "Creates a dual number from its ordinary and epsilon parts." } ;

HELP: d*
{ $values
    { "x" dual } { "y" dual }
    { "x*y" dual }
}
{ $description "Multiply dual numbers." } ;

HELP: d+
{ $values
    { "x" dual } { "y" dual }
    { "x+y" dual }
}
{ $description "Add dual numbers." } ;

HELP: d-
{ $values
    { "x" dual } { "y" dual }
    { "x-y" dual }
}
{ $description "Subtract dual numbers." } ;

HELP: d/
{ $values
    { "x" dual } { "y" dual }
    { "x/y" dual }
}
{ $description "Divide dual numbers." } 
{ $errors "Throws an error if the ordinary part of " { $snippet "x" } " is zero." } ;

HELP: d^
{ $values
    { "x" dual } { "y" dual }
    { "x^y" dual }
}
{ $description "Raise a dual number to a (possibly dual) power" } ;

HELP: dabs
{ $values
     { "x" dual }
     { "|x|" dual }
}
{ $description "Absolute value of a dual number." } ;

HELP: dacosh
{ $values
     { "x" dual }
     { "y" dual }
}
{ $description "Inverse hyberbolic cosine of a dual number." } ;

HELP: dasinh
{ $values
     { "x" dual }
     { "y" dual }
}
{ $description "Inverse hyberbolic sine of a dual number." } ;

HELP: datanh
{ $values
     { "x" dual }
     { "y" dual }
}
{ $description "Inverse hyberbolic tangent of a dual number." } ;

HELP: dneg
{ $values
     { "x" dual }
     { "-x" dual }
}
{ $description "Negative of a dual number." } ;

HELP: drecip
{ $values
     { "x" dual }
     { "1/x" dual }
}
{ $description "Reciprocal of a dual number." } ;

HELP: define-dual-method
{ $values
    { "word" word }
}
{ $description "Defines a method on the dual numbers for generic word." }
{ $notes "Uses the derivative word-prop, which holds a list of quotations giving the partial derivatives of the word with respect to each of its arguments.  This can be set using " { $link POSTPONE: DERIVATIVE: } "." } ;

{ define-dual-method dual-op POSTPONE: DERIVATIVE: } related-words

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
"Dual numbers are ordered pairs " { $snippet "<o,e>"} "--an ordinary part and an epsilon part--with component-wise addition and multiplication defined by "{ $snippet "<o1,e1>*<o2,e2> = <o1*o2,e1*o2 + e2*o1>" } ". They are analagous to complex numbers with " { $snippet "i^2 = 0" } "instead of " { $snippet "i^2 = -1" } ". For well-behaved functions " { $snippet "f" } ", " { $snippet "f(<o1,e1>) = f(o1) + e1*f'(o1)" } ", where " { $snippet "f'"} " is the derivative of " { $snippet "f" } "."
;


ABOUT: "math.dual"
