USING: compiler.cfg compiler.tree help.markup help.syntax
kernel.private ;
IN: compiler.cfg.intrinsics.misc

HELP: emit-context-object
{ $values
  { "block" "current " { $link basic-block } }
  { "node" node }
  { "block'" basic-block }
}
{ $description "Emits intrinsic code for a call to the " { $link context-object } " primitive." } ;
