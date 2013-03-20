! Copyright (C) 2012 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: help.markup help.syntax math sequences ;

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
{ $description "Return the " { $link infimum } " of " { $snippet "seq" } " ignoring any NaNs." } ;

HELP: nan-max
{ $values { "seq" sequence } { "n" number } }
{ $description "Return the " { $link supremum } " of " { $snippet "seq" } " ignoring any NaNs." } ;

HELP: sinc
{ $values { "x" number } { "y" number } }
{ $description "Returns the " { $link sinc } " function, calculated according to " { $snippet "sin(pi * x) / (pi * x)" } ". The name " { $link sinc } " is short for \"sine cardinal\" or \"sinus cardinalis\"." }
{ $notes { $snippet "0 sinc" } " is the limit value of 1." } ;

HELP: linspace
{ $values { "from" number } { "to" number } { "points" number } { "seq" sequence } }
{ $description "Return evenly spaced numbers over a specified interval " { $snippet "[from,to]" } "." } ;

HELP: logspace
{ $values { "from" number } { "to" number } { "points" number } { "base" number } { "seq" sequence } }
{ $description "Return evenly spaced numbers on a log scaled interval " { $snippet "[base^from,base^to]" } "." } ;
