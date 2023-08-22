! Copyright (C) 2017 Jon Harper.
! See https://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax kernel math quotations ;
IN: math.functions.integer-logs

HELP: integer-log10
{ $values
    { "x" "a positive rational number" }
    { "n" integer }
}
{ $description "Outputs the largest integer " { $snippet "n" } " such that " { $snippet "10^n" } " is less than or equal to " { $snippet "x" } "." }
{ $errors "Throws an error if " { $snippet "x" } " is zero or negative." } ;

HELP: integer-log2
{ $values
    { "x" "a positive rational number" }
    { "n" integer }
}
{ $description "Outputs the largest integer " { $snippet "n" } " such that " { $snippet "2^n" } " is less than or equal to " { $snippet "x" } "." }
{ $errors "Throws an error if " { $snippet "x" } " is zero or negative." } ;

ARTICLE: "integer-logs" "Integer logarithms"
"The " { $vocab-link "math.functions.integer-logs" } " vocabulary provides exact integer logarithms for all rational numbers:"
{ $subsections integer-log2 integer-log10 }
{ $examples
    { $example
        "USING: prettyprint math.functions.integer-logs sequences ;"
        "{"
        "     5 99 100 101 100000000000000000000"
        "     100+1/2 1/100"
        "} [ integer-log10 ] map ."
        "{ 0 1 2 2 20 2 -2 }"
    }
} ;

ABOUT: "integer-logs"
