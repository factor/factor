USING: compiler.tree compiler.tree.escape-analysis.nodes
help.markup help.syntax ;
IN: compiler.tree.escape-analysis.nodes+docs

HELP: escape-analysis*
{ $values { "node" node } }
{ $description "Performs escape analysis for one SSA node." } ;

ARTICLE: "compiler.tree.escape-analysis.nodes"
"Per-node dispatch for escape analysis" ;

ABOUT: "compiler.tree.escape-analysis.nodes"
