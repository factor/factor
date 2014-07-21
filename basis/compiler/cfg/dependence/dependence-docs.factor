USING: compiler.cfg.instructions help.markup help.syntax sequences ;
IN: compiler.cfg.dependence

HELP: <node>
{ $values { "insn" insn } { "node" node } }
{ $description "Creates a new dependency graph node from an CFG instruction." } ;
