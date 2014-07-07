USING: compiler.cfg compiler.cfg.instructions compiler.cfg.rpo
compiler.cfg.stack-frame help.markup help.syntax namespaces sequences vectors
words ;
IN: compiler.cfg

HELP: basic-block
{ $class-description
  "Factors representation of a basic block in the cfg. A basic block is a sequence of instructions that always are executed sequentially and doesn't contain any branching. It has the following slots:"
  { $table
    { { $slot "successors" } { "A " { $link vector } " of basic blocks that may be executed directly after this block. Most blocks only have one successor but a block that checks where an if-condition should branch to would have two for example." } }
    { { $slot "instructions" } { "A " { $link vector } " of " { $link insn } " tuples which form the instructions of the basic block." } }
  }
} ;

HELP: <basic-block>
{ $values { "bb" basic-block } }
{ $description "Creates a new empty basic block. The " { $slot "id" } " slot is initialized with the value of the basic-block " { $link counter } "." } ;

HELP: cfg
{ $class-description
  "Call flow graph. It has the following slots:"
  { $table
    { { $slot "entry" } { "Initial " { $link basic-block } " of the graph." } }
    { { $slot "word" } { "The " { $link word } " the cfg is produced from." } }
    { { $slot "post-order" } { "The blocks of the cfg in a post order traversal " { $link sequence } "." } }
    { { $slot "stack-frame" } { { $link stack-frame } " of the cfg." } }
  }
}
{ $see-also post-order } ;

HELP: cfg-changed
{ $values { "cfg" cfg } }
{ $description "Resets all \"calculated\" slots in the cfg which forces them to be recalculated." } ;
