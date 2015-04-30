USING: compiler.cfg help.markup help.syntax quotations sequences ;
IN: compiler.cfg.rpo

HELP: number-blocks
{ $values { "blocks" sequence } }
{ $description "Initializes the " { $slot "number" } " slot of each " { $link basic-block } "." }
{ $examples
  { $example
    "USING: accessors compiler.cfg compiler.cfg.rpo kernel prettyprint sequences ;"
    "10 [ <basic-block> ] replicate dup number-blocks [ number>> ] map ."
    "{ 9 8 7 6 5 4 3 2 1 0 }"
  }
} ;

HELP: post-order
{ $values { "cfg" cfg } { "blocks" sequence } }
{ $description "Lists the blocks in the cfg sorted in descending order on the " { $slot "number" } " slot. The blocks are first numbered if they haven't already been." } ;

HELP: each-basic-block
{ $values { "cfg" cfg } { "quot" quotation } }
{ $description "Applies a quotation to each basic block in the cfg." } ;

HELP: optimize-basic-block
{ $values { "bb" basic-block } { "quot" quotation } }
{ $description "Performs one " { $link simple-optimization } " step. The quotation takes the instructions of the basic block and returns them back in an optimized form." } ;

HELP: simple-analysis
{ $values { "cfg" cfg } { "quot" quotation } }
{ $description "Applies a quotation to each sequence of instructions in each " { $link basic-block } " in the cfg." } ;

HELP: simple-optimization
{ $values { "cfg" cfg } { "quot" quotation } }
{ $description "Runs a quotation that optimizes each " { $link basic-block } " in the cfg, excluding the kill blocks. The quotation takes the blocks instruction sequence and returns them back in optimized form. The blocks are iterated in " { $link reverse-post-order } "." } ;
