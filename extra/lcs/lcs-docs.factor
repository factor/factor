USING: help.syntax help.markup ;
IN: lcs

HELP: levenshtein
{ $values { "old" "a sequence" } { "new" "a sequence" } { "n" "the Levenshtein distance" } }
{ $description "Calculates the Levenshtein distance between old and new, that is, the minimal number of changes from the old sequence to the new one, in terms of deleting, inserting and replacing characters." } ;
