! Copyright (C) 2012 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: help.markup help.syntax kernel math math.functions
sequences ;

IN: math.extras

HELP: bernoulli
{ $values { "p" integer } { "n" rational } }
{ $description "Return the Bernoulli number " { $snippet "p" } "." } ;

HELP: stirling
{ $values { "n" integer } { "k" integer } { "x" integer } }
{ $description "Return the Stirling number of the second kind for a set with " { $snippet "n" } " elements partitioned into " { $snippet "k" } " disjoint non-empty sets." } ;

HELP: ramanujan
{ $values { "x" number } { "y" number } }
{ $description "Return the Ramanujan approximation of " { $snippet "factorial(x)" } "." } ;

HELP: chi2
{ $values { "actual" sequence } { "expected" sequence } { "n" real } }
{ $description "Return the chi-squared metric between " { $snippet "actual" } " and " { $snippet "expected" } " observations." } ;

HELP: chi2P
{ $values { "chi" real } { "df" real } { "p" real } }
{ $description "Returns the inverse chi-squared value according to " { $snippet "P(chi|df) = P(df/2,chi/2)" } "." } ;

HELP: bartlett
{ $values { "n" integer } { "seq" sequence } }
{ $description "Return the Bartlett window." } ;

HELP: hanning
{ $values { "n" integer } { "seq" sequence } }
{ $description "Return the Hanning window." } ;

HELP: hamming
{ $values { "n" integer } { "seq" sequence } }
{ $description "Return the Hamming window." } ;

HELP: blackman
{ $values { "n" integer } { "seq" sequence } }
{ $description "Return the Blackman window." } ;

HELP: nan-sum
{ $values { "seq" sequence } { "n" number } }
{ $description "Return the " { $link sum } " of " { $snippet "seq" } " treating any NaNs as zero." } ;

HELP: nan-min
{ $values { "seq" sequence } { "n" number } }
{ $description "Return the " { $link minimum } " of " { $snippet "seq" } " ignoring any NaNs." } ;

HELP: nan-max
{ $values { "seq" sequence } { "n" number } }
{ $description "Return the " { $link maximum } " of " { $snippet "seq" } " ignoring any NaNs." } ;

HELP: sinc
{ $values { "x" number } { "y" number } }
{ $description "Returns the " { $link sinc } " function, calculated according to " { $snippet "sin(pi * x) / (pi * x)" } ". The name " { $link sinc } " is short for \"sine cardinal\" or \"sinus cardinalis\"." }
{ $notes { $snippet "0 sinc" } " is the limit value of 1." } ;

HELP: linspace[a..b)
{ $values { "a" number } { "b" number } { "length" integer } { "seq" sequence } }
{ $description "Return evenly spaced numbers over an interval " { $snippet "[a,b)" } "." } ;

HELP: linspace[a..b]
{ $values { "a" number } { "b" number } { "length" integer } { "seq" sequence } }
{ $description "Return evenly spaced numbers over an interval " { $snippet "[a,b]" } "." } ;

HELP: logspace[a..b)
{ $values { "a" number } { "b" number } { "length" integer } { "base" number } { "seq" sequence } }
{ $description "Return evenly spaced numbers on a log scaled interval " { $snippet "[base^a,base^b)" } "." } ;

HELP: logspace[a..b]
{ $values { "a" number } { "b" number } { "length" integer } { "base" number } { "seq" sequence } }
{ $description "Return evenly spaced numbers on a log scaled interval " { $snippet "[base^a,base^b]" } "." } ;

HELP: majority
{ $values { "seq" sequence } { "elt/f" object } }
{ $description "Returns the element of " { $snippet "seq" } " that is in the majority, provided there is such an element, using a linear-time majority vote algorithm." } ;

HELP: nonzero
{ $values { "seq" sequence } { "seq'" sequence } }
{ $description "Outputs a new sequence of the same type as " { $snippet "seq" } " with all zero elements removed." } ;

HELP: round-away-from-zero
{ $values { "x" number } { "y" number } }
{ $description "Rounds " { $snippet "x" } " via " { $link ceiling } " if " { $snippet "x" } " is greater than zero, and " { $link floor } " if x is less than zero." }
{ $examples
    { $example "USING: math.extras prettyprint ;" "0.5 round-away-from-zero ." "1.0" }
    { $example "USING: math.extras prettyprint ;" "-0.5 round-away-from-zero ." "-1.0" } }
{ $see-also ceiling floor } ;

HELP: round-to-decimal
{ $values { "x" real } { "n" integer } { "y" real } }
{ $description "Outputs the number closest to " { $snippet "x" } ", rounded to " { $snippet "n" } " decimal places." }
{ $notes "The result is not necessarily an integer." }
{ $examples
    { $example "USING: math.extras prettyprint ;" "1.23456 2 round-to-decimal ." "1.23" }
    { $example "USING: math.extras prettyprint ;" "12345.6789 -3 round-to-decimal ." "12000.0" }
} ;

HELP: kahan-sum
{ $values { "seq" sequence } { "n" float } }
{ $description "Calculates the summation of the sequence using the Kahan summation algorithm." } ;
