USING: compiler.cfg compiler.cfg.stacks.local compiler.tree help.markup
help.syntax literals make math multiline quotations sequences ;
IN: compiler.cfg.builder.blocks

<<
STRING: ex-emit-trivial-block
USING: compiler.cfg.builder.blocks make prettyprint ;
begin-stack-analysis <basic-block> dup set-basic-block [ gensym ##call, drop ] emit-trivial-block predecessors>> first .
T{ basic-block
    { instructions
        V{ T{ ##call { word ( gensym ) } } T{ ##branch } }
    }
    { successors
        V{
            T{ basic-block { predecessors V{ ~circularity~ } } }
        }
    }
    { predecessors
        V{
            T{ basic-block
                { instructions V{ T{ ##branch } } }
                { successors V{ ~circularity~ } }
            }
        }
    }
}
;
>>

HELP: begin-basic-block
{ $values { "block" basic-block } { "block'" basic-block } }
{ $description "Terminates the given block and initializes a new " { $link basic-block } " to begin outputting instructions to. The new block is included in the old blocks " { $slot "successors" } "." } ;

HELP: begin-branch
{ $values
  { "block" "current " { $link basic-block } }
  { "block'" basic-block }
}
{ $description "Used to begin emitting a branch." } ;

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

HELP: emit-conditional
{ $values
  { "block" basic-block }
  { "branches" "sequence of pairs" }
  { "block'/f" { $maybe basic-block } }
}
{ $description "Emits a sequence of conditional branches to the current " { $link cfg } ". Each branch is a pair where the first item is the entry basic block and the second the branches " { $link height-state } ". 'block' is the block in which the control flow is branched and \"block'\" the block in which it converges again." } ;

HELP: emit-trivial-block
{ $values
  { "block" basic-block }
  { "quot" quotation }
  { "block'" basic-block }
}
{ $description "Combinator that emits a new trivial block, constructed by calling the supplied quotation. The quotation should not end the current block -- only add instructions to it." }
{ $examples { $unchecked-example $[ ex-emit-trivial-block ] } } ;

HELP: end-branch
{ $values
  { "block/f" { $maybe basic-block } }
  { "pair/f" "two-tuple" }
}
{ $description "The pair is a two tuple on the format { final-bb final-height }." }
{ $see-also with-branch } ;

HELP: set-basic-block
{ $values { "basic-block" basic-block } }
{ $description "Sets the given blocks as the current one. If it has any " { $slot "instructions" } " the current " { $link building } " is set to those." } ;

HELP: with-branch
{ $values
  { "block" basic-block }
  { "quot" quotation }
  { "pair/f" { $maybe "pair" } }
}
{ $description "The pair is either " { $link f } " or a two-tuple containing a " { $link basic-block } " and a " { $link height-state } " two-tuple." } ;

ARTICLE: "compiler.cfg.builder.blocks" "CFG construction utilities"
"This vocab contains utilities for that helps " { $vocab-link "compiler.cfg.builder" } " to construct CFG:s."
$nl
"Combinators:"
{ $subsections
  with-branch
}
"Creating blocks:"
{ $subsections
  begin-basic-block
  begin-branch
  emit-call-block
  emit-conditional
  emit-trivial-call
} ;

ABOUT: "compiler.cfg.builder.blocks"
