USING: compiler.cfg compiler.cfg.instructions help.markup help.syntax vectors
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
{ $description "Creates a new empty basic block." } ;

HELP: cfg
{ $class-description
  "Call flow graph. It has the following slots:"
  { $table
    { { $slot "entry" } { "Initial " { $link basic-block } " of the graph." } }
    { { $slot "word" } { "The " { $link word } " the cfg is produced from." } }
  }
} ;
