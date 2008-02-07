USING: help.markup help.syntax quotations words math
sequences ;
IN: optimizer

ARTICLE: "optimizer" "Optimizer"
"The words in the " { $vocab-link "optimizer" } " vocabulary are internal to the compiler and user code has no reason to call them."
$nl
"The main entry point into the optimizer:"
{ $subsection optimize }
{ $subsection "specializers" } ;

ABOUT: "optimizer"

HELP: optimize-1
{ $values { "node" "a dataflow graph" } { "newnode" "a dataflow graph" } { "?" "a boolean" } }
{ $description "Performs a single round of optimization on the dataflow graph, and outputs the new graph together with a new flag indicating if any changes were made." } ;

HELP: optimize
{ $values { "node" "a dataflow graph" } { "newnode" "a dataflow graph" } }
{ $description "Continues to optimize a dataflow graph until a fixed point is reached." } ;
