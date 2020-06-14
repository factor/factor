USING: compiler.cfg compiler.cfg.intrinsics.alien compiler.tree
help.markup help.syntax quotations ;
IN: compiler.cfg.intrinsics.alien+docs

HELP: inline-accessor
{ $values
  { "block" basic-block }
  { "#call" #call }
  { "quot" quotation }
  { "test" quotation }
  { "block'" basic-block }
}
{ $description "Combinator used to simplify writing intrinsic emitting code. If the 'test' quotation yields " { $link t } " when called on the '#call' nodes inputs, then the 'quot' quotation is used to emit intrinsic instructions. Otherwise a primitive call is emitted." } ;
