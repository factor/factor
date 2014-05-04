USING: compiler.cfg help.markup help.syntax ;

HELP: basic-block
{ $class-description
  "Factors representation of a basic block in the cfg. A basic block is a sequence of instructions that always are executed sequentially and doesn't contain any branching."
} ;

HELP: <basic-block>
{ $values { "bb" basic-block } }
{ $description "Creates a new empty basic block." } ;
