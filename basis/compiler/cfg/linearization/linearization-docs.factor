USING: compiler.cfg compiler.cfg.linearization compiler.codegen help.markup
help.syntax kernel macros sequences ;
IN: compiler.cfg.linearization

HELP: linearization-order
{ $values
  { "cfg" cfg }
  { "bbs" sequence }
}
{ $description "Lists the basic blocks in linearization order. That is, the order in which they will be written in the generated assembly code." }
{ $see-also generate } ;
