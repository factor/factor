USING: compiler.tree help.markup help.syntax kernel.private words ;
IN: compiler.cfg.intrinsics.misc

HELP: emit-context-object
{ $values { "node" node } }
{ $description "Emits intrinsic code for a call to the " { $link context-object } " primitive." } ;
