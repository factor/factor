USING: help.markup help.syntax kernel ;
IN: math.constants

ARTICLE: "math-constants" "Constants"
"Standard mathematical constants:"
{ $subsections
    e
    euler
    phi
    pi
    epsilon
    single-epsilon
} ;

ABOUT: "math-constants"

HELP: e
{ $values { "e" "base of natural logarithm" } } ;

HELP: euler
{ $values { "gamma" "Euler-Mascheroni constant" } }
{ $description "The Euler-Mascheroni constant, also called \"Euler's constant\" or \"the Euler constant\"." } ;

HELP: phi
{ $values { "phi" "golden ratio" } } ;

HELP: pi
{ $values { "pi" "circumference of circle with diameter 1" } } ;

HELP: epsilon
{ $values { "epsilon" "smallest double-precision floating point value you can add to 1 without underflow" } } ;

HELP: single-epsilon
{ $values { "epsilon" "smallest single-precision floating point value you can add to 1 without underflow" } } ;
