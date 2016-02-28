USING: assocs compiler.cfg help.markup help.syntax ;
IN: compiler.cfg.stacks.finalize

HELP: inserting-peeks
{ $values { "from" basic-block } { "to" basic-block } { "set" assoc } }
{ $description
  "A peek is inserted on an edge if the destination anticipates the stack location, the source does not anticipate it and it is not available from the source in a register." } ;

HELP: inserting-replaces
{ $values { "from" basic-block } { "to" basic-block } { "set" assoc } }
{ $description
  "A replace is inserted on an edge if two conditions hold:"
  { $list
    "the location is not dead at the destination, OR the location is live at the destination but not available at the destination."
    "the location is pending in the source but not the destination"
  }
} ;

{ inserting-replaces inserting-peeks } related-words

HELP: finalize-stack-shuffling
{ $values { "cfg" cfg } }
{ $description "Called to end the stack analysis." } ;

HELP: visit-edge
{ $values { "from" basic-block } { "to" basic-block } }
{ $description "If both blocks are subroutine calls, don't bother computing anything." } ;

ARTICLE: "compiler.cfg.stacks.finalize" "Stack finalization"
"This pass inserts peeks and replaces." ;

ABOUT: "compiler.cfg.stacks.finalize"
