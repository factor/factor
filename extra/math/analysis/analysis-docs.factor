USING: help.markup help.syntax math ;
IN: math.analysis

HELP: gamma
{ $values { "x" number } { "y" number } }
{ $description "Gamma function; an extension of factorial to real and complex numbers." } ;

HELP: gammaln
{ $values { "x" number } { "gamma[x]" number } }
{ $description "An alternative to " { $link gamma } " when gamma(x)'s range varies too widely." } ;

HELP: exp-int
{ $values { "x" number } { "y" number } }
{ $description "Exponential integral function." }
{ $notes "Works only for real values of " { $snippet "x" } " and is accurate to 7 decimal places." } ;

HELP: stirling-fact
{ $values { "n" integer } { "fact" integer } }
{ $description "James Stirling's factorial approximation." } ;
