USING: compiler.cfg compiler.tree help.markup help.syntax math ;
IN: compiler.cfg.builder.blocks

HELP: initial-basic-block
{ $description "Creates an initial empty " { $link basic-block } " and stores it in the basic-block dynamic variable." } ;

HELP: begin-basic-block
{ $description "Terminates the current block and initializes a new " { $link basic-block } " to begin outputting instructions to. The new block is included in the old blocks " { $slot "successors" } "." } ;

HELP: make-kill-block
{ $description "Marks the current " { $link basic-block } " being processed as a kill block." } ;

HELP: call-height
{ $values { "#call" #call } { "n" number } }
{ $description "Calculates how many items a " { $link #call } " will add or remove from the data stack." }
{ $examples
  { $example
    "USING: compiler.cfg.builder.blocks compiler.tree.builder prettyprint sequences ;"
    "[ 3append ] build-tree second call-height ."
    "-2"
  }
} ;
