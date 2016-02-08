USING: compiler.cfg compiler.cfg.stacks.local compiler.tree help.markup
help.syntax literals make math multiline quotations sequences ;
IN: compiler.cfg.builder.blocks

<<
STRING: ex-emit-trivial-block
USING: compiler.cfg.builder.blocks make prettyprint ;
<basic-block> set-basic-block [ [ gensym ##call, ] emit-trivial-block ] { } make drop basic-block get .
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
{ $values { "block" basic-block } }
{ $description "Terminates the given block and initializes a new " { $link basic-block } " to begin outputting instructions to. The new block is included in the old blocks " { $slot "successors" } "." } ;

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
{ $description "Combinator that emits a new trivial block, constructed by calling the supplied quotation. The quotation should not end the current block -- only add instructions to it." }
{ $examples { $unchecked-example $[ ex-emit-trivial-block ] } } ;

HELP: end-branch
{ $values { "block" basic-block } { "pair/f" "two-tuple" } }
{ $description "pair is { final-bb final-height }" } ;

HELP: make-kill-block
{ $values { "block" basic-block } }
{ $description "Marks the block as a kill block." } ;

HELP: set-basic-block
{ $values { "basic-block" basic-block } }
{ $description "Sets the given blocks as the current one by storing it in the basic-block dynamic variable. If it has any " { $slot "instructions" } " the current " { $link building } " is set to those." } ;

HELP: with-branch
{ $values { "quot" quotation } { "pair/f" { $maybe "pair" } } }
{ $description "The pair is either " { $link f } " or a two-tuple containing a " { $link basic-block } " and a " { $link height-state } " two-tuple." } ;
