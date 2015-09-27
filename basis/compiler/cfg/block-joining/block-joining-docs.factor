USING: compiler.cfg compiler.cfg.instructions help.markup help.syntax kernel ;
IN: compiler.cfg.block-joining

HELP: join-block?
{ $values { "bb" basic-block } { "?" boolean } }
{ $description "Whether the block can be joined with its predecessor or not. Two blocks can only be joined if:"
  { $list
    "Neither of them are kill blocks"
    "They have only one predecessor and it has only one successor"
    "The predecessor has a lower block number"
  }
} ;

HELP: join-blocks
{ $values { "cfg" cfg } }
{ $description "A compiler pass when optimizing the cfg." } ;

ARTICLE: "compiler.cfg.block-joining" "Block Joining"
"Joining blocks that are not calls and are connected by a single CFG edge. This pass does not update " { $link ##phi } " nodes and should therefore only run before stack analysis or after ##phi node elimination." ;

ABOUT: "compiler.cfg.block-joining"
