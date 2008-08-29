USING: help.markup help.syntax sequences quotations words 
compiler.tree stack-checker.errors ;
IN: compiler.tree.builder

HELP: build-tree
{ $values { "quot" quotation } { "nodes" "a sequence of nodes" } }
{ $description "Attempts to construct tree SSA IR from a quotation." }
{ $notes "This is the first stage of the compiler." }
{ $errors "Throws an " { $link inference-error } " if stack effect inference fails." } ;

HELP: build-tree-with
{ $values { "in-stack" "a sequence of values" } { "quot" quotation } { "nodes" "a sequence of nodes" } { "out-stack" "a sequence of values" } }
{ $description "Attempts to construct tree SSA IR from a quotation, starting with an initial data stack of values, and outputting stack resulting at the end." }
{ $errors "Throws an " { $link inference-error } " if stack effect inference fails." } ;
