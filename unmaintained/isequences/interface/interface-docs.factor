USING: help.markup help.syntax isequences.interface ;

HELP: i-at 
{ $values { "s" "an isequence" } { "n" "an isequence" } { "v" "the element at the " { $snippet "n" } "th index" } }
{ $contract "Outputs the element at position" { $snippet "n" } "of the isequence." } ;

HELP: --
{ $values { "s" "an isequence" } { "-s" "a negated isequence" } }
{ $contract "Outputs the negated version of " { $snippet "s"} " with its length and indices negated." } ;

HELP: i-length
{ $values { "s" "an isequence" } { "n" "an integer length" } }
{ $contract "Outputs the length of " { $snippet "s" } " which can be negative for a negated isequence." } ;

HELP: ++
{ $values { "s1" "an isequence" } { "s2" "an isequence" } { "s" "the concatenated result of " { $snippet "s1" } " and " { $snippet "s2" } } }
{ $contract "Outputs the freshly concatened isequence with length = length(s1) + length(s2)." } ;
