USING: compiler.cfg compiler.tree help.markup help.syntax literals math
multiline quotations ;
IN: compiler.cfg.builder.blocks

<<
STRING: ex-emit-trivial-block
USING: compiler.cfg.builder.blocks prettyprint ;
initial-basic-block [ [ gensym ##call, ] emit-trivial-block ] { } make drop
basic-block get .
T{ basic-block
    { id 2040412 }
    { successors
        V{
            T{ basic-block
                { id 2040413 }
                { instructions
                    V{
                        T{ ##call { word ( gensym ) } }
                        T{ ##branch }
                    }
                }
                { successors
                    V{ T{ basic-block { id 2040414 } } }
                }
            }
        }
    }
}
;
>>

HELP: begin-basic-block
{ $description "Terminates the current block and initializes a new " { $link basic-block } " to begin outputting instructions to. The new block is included in the old blocks " { $slot "successors" } "." } ;

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

HELP: emit-trivial-block
{ $values { "quot" quotation } }
{ $description "Combinator that emits a trivial block, constructed by calling the supplied quotation." }
{ $examples { $unchecked-example $[ ex-emit-trivial-block ] } } ;

HELP: initial-basic-block
{ $description "Creates an initial empty " { $link basic-block } " and stores it in the basic-block dynamic variable." } ;

HELP: make-kill-block
{ $description "Marks the current " { $link basic-block } " being processed as a kill block." } ;
