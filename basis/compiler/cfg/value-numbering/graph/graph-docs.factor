USING: help.markup help.syntax ;
IN: compiler.cfg.value-numbering.graph

HELP: vregs>vns
{ $var-description "assoc mapping vregs to value numbers this is the identity on canonical representatives." } ;

HELP: exprs>vns
{ $var-description "assoc mapping expressions to value numbers." } ;

HELP: vns>insns
{ $var-description "assoc mapping value numbers to instructions." } ;

ABOUT: "compiler.cfg.value-numbering.graph"
