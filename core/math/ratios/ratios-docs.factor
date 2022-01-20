USING: help.markup help.syntax math math.ratios.private ;
IN: math.ratios

ARTICLE: "rationals" "Rational numbers"
{ $subsections ratio }
"When we add, subtract or multiply any two integers, the result is always an integer. However, dividing a numerator by a denominator that is not an integral divisor of the denominator yields a ratio:"
{ $example "1210 11 / ." "110" }
{ $example "100 330 / ." "10/33" }
{ $example "14 10 / ." "1+2/5" }
"Ratios are printed and can be input literally in the form above. Ratios are always reduced to lowest terms by factoring out the greatest common divisor of the numerator and denominator. A ratio with a denominator of 1 becomes an integer. Division with a denominator of 0 throws an error."
$nl
"Ratios behave just like any other number -- all numerical operations work as you would expect."
{ $example "1/2 1/3 + ." "5/6" }
{ $example "100 6 / 3 * ." "50" }
"Ratios can be taken apart:"
{ $subsections
    numerator
    denominator
    >fraction
}
{ $see-also "syntax-ratios" } ;

ABOUT: "rationals"

HELP: ratio
{ $class-description "The class of rational numbers with denominator not equal to 1." } ;

HELP: rational
{ $class-description "The class of rational numbers, a disjoint union of integers and ratios." } ;

HELP: numerator
{ $values { "a/b" rational } { "a" integer } }
{ $description "Outputs the numerator of a rational number. Acts as the identity on integers." } ;

HELP: denominator
{ $values { "a/b" rational } { "b" "a positive integer" } }
{ $description "Outputs the denominator of a rational number. Always outputs 1 with integers." } ;

HELP: fraction>
{ $values { "a" integer } { "b" "a positive integer" } { "a/b" rational } }
{ $description "Creates a new ratio, or outputs the numerator if the denominator is 1. This word does not reduce the fraction to lowest terms, and should not be called directly; use " { $link / } " instead." } ;

HELP: >fraction
{ $values { "a/b" rational } { "a" integer } { "b" "a positive integer" } }
{ $description "Extracts the numerator and denominator of a rational number." } ;

HELP: 2>fraction
{ $values { "a/b" rational } { "c/d" rational } { "a" integer } { "c" integer } { "b" "a positive integer" } { "d" "a positive integer" } }
{ $description "Extracts the numerator and denominator of two rational numbers at once." } ;
