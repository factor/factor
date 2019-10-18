USING: classes compiler.tree help.markup help.syntax kernel sequences
;
IN: compiler.tree.cleanup

HELP: (cleanup-folding)
{ $values { "#call" #call } { "nodes" sequence } }
{ $description "Replace a #call having a known result with a #drop of its inputs followed by #push nodes for the outputs." } ;

HELP: >copy
{ $values { "node" node } { "#copy" #copy } }
{ $description "Creates a #copy node from the inputs and outputs of a node." } ;

HELP: cleanup-folding?
{ $values { "#call" #call } { "?" boolean } }
{ $description "Checks if a " { $link #call } " node can be folded." } ;

HELP: cleanup-tree
{ $values { "nodes" sequence } { "nodes'" sequence } }
{ $description "Main entry point for the cleanup-tree optimization phase. We don't recurse into children here, instead the methods do it since the logic is a bit more involved." }
{ $see-also cleanup-tree* } ;

HELP: cleanup-tree*
{ $values { "node" node } { "node/nodes" "a node or a sequence of nodes" } }
{ $description "Runs the cleanup pass for an SSA node." } ;

HELP: flatten-recursive
{ $values { "#recursive" #recursive } { "nodes" sequence } }
{ $description "Converts " { $link #enter-recursive } " and " { $link #return-recursive } " into " { $link #copy } " nodes." } ;

HELP: fold-only-branch
{ $values { "#branch" #branch } { "node/nodes" "a " { $link node } " or a sequence of nodes" } }
{ $description "If only one branch is live we don't need to branch at all; just drop the condition value." } ;

HELP: record-predicate-folding
{ $values { "#call" #call } }
{ $description "Adds a suitable dependency for a call to a word that is a " { $link predicate } " word that has been folded." } ;

ARTICLE: "compiler.tree.cleanup" "Cleanup Phase"
"A phase run after propagation to finish the job, so to speak. Codifies speculative inlining decisions, deletes branches marked as never taken, replaces folded calls with constants and flattens local recursive blocks that do not call themselves."
$nl
"Main entry point:"
{ $subsections cleanup-tree }
"Each node type implements its own method on the " { $link cleanup-tree* } " generic."
$nl
"Previous pass: " { $vocab-link "compiler.tree.propagation" } ", next pass: " { $vocab-link "compiler.tree.escape-analysis" } "." ;

ABOUT: "compiler.tree.cleanup"
