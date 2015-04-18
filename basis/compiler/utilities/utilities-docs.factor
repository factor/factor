USING: assocs compiler.cfg.ssa.destruction.leaders help.markup help.syntax math
sequences ;
IN: compiler.utilities

HELP: compress-path
{ $values { "source" integer } { "assoc" assoc } { "destination" integer } }
{ $description "Gets the original definer for a vreg number. Then inserts a direct path from 'source' to that definer. For example if the assoc is " { $code "{ { 1 2 } { 2 3 } { 3 4 } { 4 4 } }" } "then the original definer of 1 is 4. The word is used by " { $link leader } " to figure out what the top leader of a vreg is." } ;
