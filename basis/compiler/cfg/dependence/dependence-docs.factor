USING: assocs compiler.cfg.instructions help.markup help.syntax math
sequences ;
IN: compiler.cfg.dependence

HELP: node
{ $class-description "Nodes in the dependency graph. These need to be numbered so that the same instruction will get distinct nodes if it occurs multiple times. It has the following slots:"
  { $table
    { { $slot "insn" } { { $link insn } } }
    { { $slot "precedes" } { "Hash of all nodes this node must precede in the instruction flow." } }
  }
} ;

HELP: <node>
{ $values { "insn" insn } { "node" node } }
{ $description "Creates a new dependency graph node from an CFG instruction." } ;

{ node <node> } related-words

HELP: attach-parent
{ $values { "child" node } { "parent" node } }
{ $description "Inserts 'node' as a children of 'parent' and sets the parent of 'node' to 'parent'." }
{ $examples
  { $unchecked-example
    "USING: compiler.cfg.dependence ;"
    "T{ ##replace } T{ ##set-slot-imm } [ <node> ] bi@ attach-parent"
  }
} ;

HELP: select-parent
{ $values { "precedes" assoc } { "parent/f" node } }
{ $description "Picks the parent node for this node from an assoc of preceding nodes." } ;

HELP: build-fan-in-trees
{ $values { "nodes" sequence } }
{ $description "Selects a parent for each " { $link node } ", then initializes the " { $slot "parent-index" } " and Sethi-Ulmann number for the nodes." } ;

HELP: calculate-registers
{ $values { "node" node } { "registers" integer } }
{ $description "Calculates a nodes Sethi-Ulmann number. For a leaf node, the number is equal to the number of temporary registers the word uses." } ;

ARTICLE: "compiler.cfg.dependence" "Dependence graph construction"
"This vocab is used by " { $vocab-link "compiler.cfg.scheduling" } "." ;

ABOUT: "compiler.cfg.dependence"
