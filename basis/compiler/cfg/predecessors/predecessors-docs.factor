USING: compiler.cfg help.markup help.syntax kernel ;
IN: compiler.cfg.predecessors

HELP: needs-predecessors
{ $values { "cfg" cfg } }
{ $description "Computes predecessor info for the cfg unless it already is up-to-date." } ;
