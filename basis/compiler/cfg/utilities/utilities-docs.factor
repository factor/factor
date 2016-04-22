USING: assocs compiler.cfg hashtables help.markup help.syntax
sequences ;
IN: compiler.cfg.utilities

HELP: connect-Nto1-bbs
{ $values { "froms" sequence } { "to" basic-block } }
{ $description "Connects all basic blocks in 'froms' so that 'to' is a successor of them all." } ;

HELP: insert-basic-block
{ $values { "from" basic-block } { "to" basic-block } { "insns" sequence } }
{ $description "Insert basic block on the edge between 'from' and 'to'." } ;

ARTICLE: "compiler.cfg.utilities" "Utility words used by CFG optimization"
"Various utilities."
$nl
"For " { $vocab-link "heaps" } ":"
{ $subsections
  heap-members
  heap-pop-while
}
"For " { $vocab-link "deques" } ":"
{ $subsections
  slurp/replenish-deque
} ;

ABOUT: "compiler.cfg.utilities"
