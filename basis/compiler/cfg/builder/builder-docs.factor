USING: arrays assocs compiler.cfg compiler.cfg.builder.blocks
compiler.cfg.instructions compiler.cfg.stacks.local
compiler.tree help.markup help.syntax kernel literals math
multiline quotations sequences vectors words ;
IN: compiler.cfg.builder

<<
STRING: ex-emit-call
USING: compiler.cfg.builder compiler.cfg.builder.blocks compiler.cfg.stacks
kernel make prettyprint ;
begin-stack-analysis <basic-block> set-basic-block
\ dummy 3 [ emit-call ] { } make drop
height-state basic-block [ get . ] bi@
{ { 3 0 } { 0 0 } }
T{ basic-block
    { id 1903165 }
    { successors
        V{
            T{ basic-block
                { id 1903166 }
                { instructions
                    V{
                        T{ ##call { word dummy } }
                        T{ ##branch }
                    }
                }
                { successors
                    V{ T{ basic-block { id 1903167 } } }
                }
                { kill-block? t }
            }
        }
    }
}
;

STRING: ex-make-input-map
USING: compiler.cfg.builder prettyprint ;
T{ #shuffle { in-d { 37 81 92 } } } make-input-map .
{ { 37 D: 2 } { 81 D: 1 } { 92 D: 0 } }
;
>>

HELP: build-cfg
{ $values { "nodes" sequence } { "word" word } { "procedures" sequence } }
{ $description "Builds one or more cfgs from the given word." } ;

HELP: procedures
{ $var-description "A " { $link vector } " used as temporary storage during cfg construction for all procedures being built." }
{ $see-also build-cfg } ;

HELP: make-input-map
{ $values { "#shuffle" #shuffle } { "assoc" assoc } }
{ $description "Creates an " { $link assoc } " that maps input values to the shuffle operation to stack locations." }
{ $examples { $unchecked-example $[ ex-make-input-map ] } } ;

HELP: emit-call
{ $values
  { "block" basic-block }
  { "word" word }
  { "height" number }
  { "block'" basic-block }
}
{ $description
  "Emits a call to the given word to the " { $link cfg } " being constructed. \"height\" is the number of items being added to or removed from the data stack."
  $nl
  "Side effects of the word is that it modifies the \"basic-block\" and " { $link height-state } " variables."
}
{ $examples
  "In this example, a call to a dummy word is emitted which pushes three items onto the stack."
  { $unchecked-example $[ ex-emit-call ] }
}
{ $see-also call-height } ;

HELP: emit-loop-call
{ $values { "successor-block" basic-block } { "current-block" basic-block } }
{ $description "Sets the given block as the successor of the current block. Then ends the block." } ;

HELP: emit-node
{ $values { "block" basic-block } { "node" node } { "block'" basic-block } }
{ $description "Emits CFG instructions for the given SSA node. The word can add one or more basic blocks to the " { $link cfg } ". The next block to operate on is pushed onto the stack."
$nl
"The following classes emit-node methods does not change the current block:"
  { $list
    { $link #alien-assembly }
    { $link #alien-callback }
    { $link #alien-indirect }
  }
} ;

HELP: emit-nodes
{ $values
  { "block" "current " { $link basic-block } }
  { "nodes" sequence }
  { "block'" basic-block }
}
{ $description "Emits all tree nodes to the cfg. The next block to operate on is pushed onto the stack." } ;

HELP: end-word
{ $values
  { "block" "current " { $link basic-block } }
  { "block'" basic-block }
}
{ $description "Ends the word by adding a basic block containing a " { $link ##return } " instructions to the " { $link cfg } "." } ;

HELP: height-changes
{ $values { "#shuffle" #shuffle } { "height-changes" pair } }
{ $description "Returns a two-tuple which represents how much the " { $link #shuffle } " node increases or decreases the data and retainstacks." }
{ $examples
  { $example
    "USING: compiler.cfg.builder compiler.tree prettyprint ;"
    "T{ #shuffle { in-d { 37 81 92 } } { out-d { 20 } } } height-changes ."
    "{ -2 0 }"
  }
} ;

HELP: out-vregs/stack
{ $values { "#shuffle" #shuffle } { "pair" sequence } }
{ $description "Returns a sequence of what vregs are on which stack locations after the shuffle instruction." } ;

HELP: trivial-branch?
{ $values
  { "nodes" "a " { $link sequence } " of " { $link node } " instances" }
  { "value" { $maybe "the pushed value" } }
  { "?" boolean }
}
{ $description "Checks whether nodes is a trivial branch or not. The branch is counted as trivial if all it does is push a literal value on the stack." }
{ $examples
  { $example
    "USING: compiler.cfg.builder compiler.tree prettyprint ;"
    "{ T{ #push { literal 25 } } } trivial-branch? . ."
    "t\n25"
  }
} ;

HELP: with-cfg-builder
{ $values { "nodes" sequence } { "word" word } { "label" word } { "quot" quotation } }
{ $description "Combinator used to begin and end stack analysis so that the given quotation can build the cfg. The quotation is passed the initial basic block on the stack." } ;

ARTICLE: "compiler.cfg.builder"
"Final stage of compilation generates machine code from dataflow IR"
"The compiler first builds an SSA IR tree of the word to be compiled (see " { $vocab-link "compiler.tree.builder" } ") then this vocab converts it to a CFG IR tree. The result is not in SSA form; this is constructed later by calling compiler.cfg.ssa.construction:construct-ssa."
$nl
"Each tree node type has its own implementation of the " { $link emit-node } " generic. In that word, cfg instructions (tuples prefixed with ##) are output to basic blocks and the cfg constructed."
$nl
"Main word:"
{ $subsections
  build-cfg
}
"Block adders:"
{ $subsections
  begin-word
  end-word
}
"Combinators:"
{ $subsections
    with-cfg-builder
}
"Emitters for " { $link #call } ":"
{ $subsections
  emit-call
  emit-loop-call
}
"Emitters for " { $link #dispatch } " and " { $link #if } ":"
{ $subsections
  emit-actual-if
  emit-branch
  emit-if
  emit-trivial-if
}
"Emitters for " { $link #recursive } ":"
{
    $subsections
    emit-loop
    emit-recursive
    end-branch
}
"Helpers for " { $link #shuffle } ":"
{
    $subsections
    height-changes
    out-vregs/stack
} ;

ABOUT: "compiler.cfg.builder"
