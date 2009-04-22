USING: help.markup help.syntax sequences quotations words 
compiler.tree stack-checker.errors ;
IN: compiler.tree.builder

HELP: build-tree
{ $values { "quot/word" { $or quotation word } } { "nodes" "a sequence of nodes" } }
{ $description "Attempts to construct tree SSA IR from a quotation." }
{ $notes "This is the first stage of the compiler." }
{ $errors "Throws an " { $link inference-error } " if stack effect inference fails." } ;

HELP: build-sub-tree
{ $values { "#call" #call } { "quot/word" { $or quotation word } } { "nodes" { $maybe "a sequence of nodes" } } }
{ $description "Attempts to construct tree SSA IR from a quotation, starting with an initial data stack of values from the call site. Outputs " { $link f } " if stack effect inference fails." } ;
