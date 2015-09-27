USING: compiler.cfg compiler.cfg.utilities help.markup help.syntax ;
IN: compiler.cfg.branch-splitting

HELP: clone-basic-block
{ $values { "bb" basic-block } { "bb'" basic-block } }
{ $description "The new block temporarily gets the same RPO number as the old one, until the next time RPO is computed. This is just to make " { $link back-edge? } " work." } ;
