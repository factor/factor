USING: help.markup help.syntax ;
IN: math.continued-fractions

HELP: approx
{ $values { "epsilon" "a positive floating point number representing the absolute acceptable error" } { "float" "a positive floating point number to approximate" } { "a/b" "a fractional number containing the approximation" } }
{ $description "Give a rational approximation of " { $snippet "float" } " with a precision of " { $snippet "epsilon" } " using the smallest possible denominator." } ;

HELP: >ratio
{ $values { "seq" "a sequence representing a continued fraction" } { "a/b" "a fractional number" } }
{ $description "Transform " { $snippet "seq" } " into its rational representation." } ;

HELP: next-approx
{ $values { "seq" "a mutable sequence" } }
{ $description "Compute the next step in continued fraction calculation." } ;
