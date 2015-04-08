USING: compiler.cfg compiler.cfg.instructions help.markup help.syntax ;
IN: compiler.cfg.block-joining

HELP: join-block?
{ $values { "bb" basic-block } { "?" "a boolean" } }
{ $description "Whether the block can be joined with its predecessor or not." } ;

HELP: join-blocks
{ $values { "cfg" cfg } }
{ $description "A compiler pass when optimizing the cfg." } ;

ARTICLE: "compiler.cfg.block-joining" "Block Joining"
"Joining blocks that are not calls and are connected by a single CFG edge. This pass does not update " { $link ##phi } " nodes and should therefore only run before stack analysis." ;

ABOUT: "compiler.cfg.block-joining"
