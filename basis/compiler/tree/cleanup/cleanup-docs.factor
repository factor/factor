USING: compiler.tree help.markup help.syntax kernel sequences ;
IN: compiler.tree.cleanup

HELP: cleanup-folding?
{ $values { "#call" #call } { "?" boolean } }
{ $description "Checks if a " { $link #call } " node can be folded." } ;

HELP: cleanup-tree
{ $values { "nodes" sequence } { "nodes'" sequence } }
{ $description "Main entry point for the cleanup-tree optimization phase." } ;

ARTICLE: "compiler.tree.cleanup" "Cleanup Phase"
"A phase run after propagation to finish the job, so to speak. Codifies speculative inlining decisions, deletes branches marked as never taken, and flattens local recursive blocks that do not call themselves." ;

ABOUT: "compiler.tree.cleanup"
