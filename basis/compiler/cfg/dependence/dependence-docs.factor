USING: compiler.cfg.instructions help.markup help.syntax sequences ;
IN: compiler.cfg.dependence

HELP: node
{ $class-description "Nodes in the dependency graph. These need to be numbered so that the same instruction will get distinct nodes if it occurs multiple times. It has the following slots:"
  { $table
    { { $slot "number" } { "Sequence number to differentiate two otherwise equal nodes from each other. " } }
    { { $slot "insn" } { { $link insn } } }
    { { $slot "parent" } { "Node which must precede this node in the instruction flow." } }
  }
} ;

HELP: <node>
{ $values { "insn" insn } { "node" node } }
{ $description "Creates a new dependency graph node from an CFG instruction." } ;

{ node <node> } related-words

HELP: attach-parent
{ $values { "node" node } { "parent" node } }
{ $description "Inserts 'node' as a children of 'parent' and sets the parent of 'node' to 'parent'." }
{ $examples
  { $unchecked-example
    "USING: compiler.cfg.dependence ;"
    "T{ ##replace } T{ ##set-slot-imm } [ <node> ] bi@ attach-parent"
  }
} ;


ARTICLE: "compiler.cfg.dependence" "Dependence graph construction"
"This vocab is used by " { $vocab-link "compiler.cfg.scheduling" } "." ;

ABOUT: "compiler.cfg.dependence"
