USING: compiler.cfg help.markup help.syntax ;
IN: compiler.cfg.block-joining

HELP: join-block?
{ $values { "bb" basic-block } { "?" "a boolean" } }
{ $description "Whether the block can be joined with its predecessor or not." } ;
