USING: compiler.cfg help.markup help.syntax sequences ;
IN: compiler.cfg.utilities

HELP: insert-basic-block
{ $values { "from" basic-block } { "to" basic-block } { "insns" sequence } }
{ $description "Insert basic block on the edge between 'from' and 'to'." } ;
