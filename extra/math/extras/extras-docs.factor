! Copyright (C) 2012 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: help.markup help.syntax math sequences ;

IN: math.extras

HELP: bernoulli
{ $values { "p" integer } { "n" rational } }
{ $description "Return the Bernoulli number " { $snippet "p" } "." } ;

HELP: sterling
{ $values { "n" integer } { "k" integer } { "x" integer } }
{ $description "Return the Stirling number of the second kind for a set with " { $snippet "n" } " elements partitioned into " { $snippet "k" } " disjoint non-empty sets." } ;

HELP: chi2
{ $values { "actual" sequence } { "expected" sequence } { "n" real } }
{ $description "Return the chi-squared metric between " { $snippet "actual" } " and " { $snippet "expected" } " observations." } ;

HELP: chi2P
{ $values { "chi" real } { "df" real } { "p" real } }
{ $description "Returns the inverse chi-squared value according to " { $snippet "P(chi|df) = P(df/2,chi/2)" } "." } ;

