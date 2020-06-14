USING: compiler.cfg compiler.cfg.branch-splitting
compiler.cfg.utilities help.markup help.syntax kernel sequences
splitting strings ;
IN: compiler.cfg.branch-splitting+docs

HELP: clone-basic-block
{ $values { "bb" basic-block } { "bb'" basic-block } }
{ $description "The new block temporarily gets the same RPO number as the old one, until the next time RPO is computed. This is just to make " { $link back-edge? } " work." } ;
