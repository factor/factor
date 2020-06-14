USING: compiler.tree.escape-analysis.check help.markup
help.syntax kernel sequences ;
IN: compiler.tree.escape-analysis.check+docs

HELP: run-escape-analysis?
{ $values { "nodes" sequence } { "?" boolean } }
{ $description "Whether to run escape analysis on the nodes or not." } ;

ARTICLE: "compiler.tree.escape-analysis.check"
"Skipping escape analysis pass for code which does not allocate" ;

ABOUT: "compiler.tree.escape-analysis.check"
