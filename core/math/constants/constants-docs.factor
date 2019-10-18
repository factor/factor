USING: help.markup help.syntax kernel layouts ;
IN: math.constants

ARTICLE: "math-constants" "Constants"
"Standard mathematical constants:"
{ $subsection i }
{ $subsection -i }
{ $subsection e }
{ $subsection pi }
"Various limits:"
{ $subsection most-positive-fixnum }
{ $subsection most-negative-fixnum }
{ $subsection epsilon } ;

ABOUT: "math-constants"

HELP: i
{ $values { "i" "the imaginary unit" } } ;

HELP: -i
{ $values { "-i" "the negated imaginary unit" } } ;

HELP: e
{ $values { "e" "base of natural logarithm" } } ;

HELP: pi
{ $values { "pi" "circumference of circle with diameter 1" } } ;

HELP: epsilon
{ $values { "epsilon" "smallest floating point value you can add to 1 without underflow" } } ;
