USING: compiler.cfg help.markup help.syntax sequences ;
IN: compiler.cfg.utilities

HELP: connect-Nto1-bbs
{ $values { "froms" sequence } { "to" basic-block } }
{ $description "Connects all basic blocks in 'froms' so that 'to' is a successor of them all." } ;

HELP: insert-basic-block
{ $values { "from" basic-block } { "to" basic-block } { "insns" sequence } }
{ $description "Insert basic block on the edge between 'from' and 'to'." } ;
