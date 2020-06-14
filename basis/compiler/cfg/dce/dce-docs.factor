USING: compiler.cfg compiler.cfg.dce help.markup help.syntax
math sequences ;
IN: compiler.cfg.dce+docs

HELP: eliminate-dead-code
{ $values { "cfg" cfg } }
{ $description "Even though we don't use predecessors directly, we depend on the predecessors pass updating phi nodes to remove dead inputs." } ;

ARTICLE: "compiler.cfg.dce" "Dead code elimination"
"Eliminates dead code." ;

ABOUT: "compiler.cfg.dce"
