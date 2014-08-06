USING: compiler.cfg compiler.cfg.linearization compiler.codegen help.markup
help.syntax kernel macros math sequences ;
IN: compiler.cfg.linearization

HELP: linearization-order
{ $values
  { "cfg" cfg }
  { "bbs" sequence }
}
{ $description "Lists the basic blocks in linearization order. That is, the order in which they will be written in the generated assembly code." }
{ $see-also generate } ;

HELP: block-number
{ $values { "bb" basic-block } { "n" integer } }
{ $description "Retrieves this blocks block number. Must not be called before " { $link number-blocks } "." } ;

HELP: number-blocks
{ $values { "bbs" sequence } }
{ $description "Associate each block with a block number and save the result in the " { $link numbers } " map." } ;
