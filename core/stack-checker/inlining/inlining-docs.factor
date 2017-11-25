USING: compiler.tree help.markup help.syntax words ;
IN: stack-checker.inlining

HELP: inline-recursive-word
{ $values { "word" word } }
{ $description "Emits an " { $link #recursive } " ssa node for a call to the given inline recursive word." } ;

HELP: prepare-stack
{ $values { "word" word } }
{ $description "Called when an inline recursive word is compiled." } ;
