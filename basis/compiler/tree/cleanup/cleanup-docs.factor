USING: help.markup help.syntax sequences ;
IN: compiler.tree.cleanup

ARTICLE: "compiler.tree.cleanup" "Cleanup Phase"
"A phase run after propagation to finish the job, so to speak. Codifies speculative inlining decisions, deletes branches marked as never taken, and flattens local recursive blocks that do not call themselves." ;

HELP: cleanup-tree
{ $values { "nodes" sequence } { "nodes'" sequence } }
{ $description "Main entry point for the cleanup-tree optimization phase." } ;
