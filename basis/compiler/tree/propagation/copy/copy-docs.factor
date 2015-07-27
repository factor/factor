USING: help.markup help.syntax math sequences ;
IN: compiler.tree.propagation.copy

HELP: compute-phi-equiv
{ $values { "inputs" sequence } { "outputs" sequence } }
{ $description "An output is a copy of every input if all inputs are copies of the same original value." } ;

HELP: copies
{ $var-description "Mapping from values to their canonical leader" } ;

HELP: resolve-copy
{ $values { "copy" integer } { "val" integer } }
{ $description "Gets the original definer of this SSA value." } ;

ARTICLE: "compiler.tree.propagation.copy"
"Copy propagation"
"Two values are copy-equivalent if they are always identical at run-time (\"DS\" relation). This is just a weak form of value numbering." ;

ABOUT: "compiler.tree.propagation.copy"
