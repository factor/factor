USING: compiler.cfg compiler.cfg.linearization compiler.cfg.rpo
compiler.codegen help.markup help.syntax kernel macros math sequences ;
IN: compiler.cfg.linearization

HELP: linearization-order
{ $values
  { "cfg" cfg }
  { "bbs" sequence }
}
{ $description "Lists the basic blocks in linearization order. That is, the order in which they will be written in the generated assembly code." }
{ $see-also generate reverse-post-order } ;

HELP: number-blocks
{ $values { "bbs" sequence } }
{ $description "Assigns the " { $slot "number" } " slot of each " { $link basic-block } " given it's sequence index." } ;
