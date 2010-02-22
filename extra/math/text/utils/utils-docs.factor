USING: help.markup help.syntax ;
IN: math.text.utils

HELP: digit-groups
{ $values { "n" "a positive integer" } { "k" "a positive integer" } { "seq" "a sequence" } }
{ $description "Decompose a number into groups of " { $snippet "k" } " digits and return them in a sequence starting with the least significant grouped digits first." } ;
