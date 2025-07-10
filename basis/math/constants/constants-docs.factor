USING: help.markup help.syntax kernel math ;
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
{ $values { "e" number } }
{ $description "The base of natural logarithm, sometimes called Euler's number or Napier's constant." } ;

HELP: euler
{ $values { "gamma" number } }
{ $description "The Euler-Mascheroni constant, also called \"Euler's constant\" or \"the Euler constant\"." } ;

HELP: phi
{ $values { "phi" number } }
{ $description "The golden ratio, also known as the golden number, golden proportion, or the divine proportion. Usually written as the Greek letter phi." } ;

HELP: pi
{ $values { "pi" number } }
{ $description "The ratio of a circle's circumference to its diameter." } ;

HELP: 2pi
{ $values { "2pi" number } }
{ $description "The ratio of a circle's circumference to its radius." } ;

HELP: epsilon
{ $values { "epsilon" number } }
{ $description "The smallest double-precision floating point value you can add to 1 without underflow" } ;

HELP: single-epsilon
{ $values { "epsilon" number } }
{ $description "The smallest single-precision floating point value you can add to 1 without underflow" } ;
