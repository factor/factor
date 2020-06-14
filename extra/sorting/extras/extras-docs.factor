USING: help.markup help.syntax sequences sorting.extras ;
IN: sorting.extras+docs

HELP: map-sort
{ $values { "seq" sequence } { "quot" { $quotation ( ... elt -- ... key ) } } { "sortedseq" "a new sorted sequence" } }
{ $description "Sort the elements of " { $snippet "seq" } " a sequence using " { $snippet "quot" } " as a key function." } ;
