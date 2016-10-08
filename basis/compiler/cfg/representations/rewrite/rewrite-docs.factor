USING: compiler.cfg compiler.cfg.instructions help.markup help.syntax
sequences ;
IN: compiler.cfg.representations.rewrite

HELP: alternatives
{ $var-description "Mapping from vreg,rep pairs to vregs." } ;

HELP: conversions-for-block
{ $values { "insns" sequence } }
{ $description "Inserts the required conversions in the blocks instruction sequence." } ;

HELP: insert-conversions
{ $values { "cfg" cfg } }
{ $description "The last step in " { $vocab-link "compiler.cfg.representations" } ". Here instructions such as " { $link ##shl-imm } " and " { $link ##shr-imm } " are inserted to convert between tagged and untagged value types." } ;
