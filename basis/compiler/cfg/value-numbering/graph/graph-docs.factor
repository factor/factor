USING: help.markup help.syntax ;
IN: compiler.cfg.value-numbering.graph

HELP: vregs>vns
{ $var-description "assoc mapping vregs to value numbers this is the identity on canonical representatives." } ;

HELP: exprs>vns
{ $var-description "assoc mapping expressions to value numbers." } ;

HELP: vns>insns
{ $var-description "assoc mapping value numbers to instructions." } ;

ARTICLE: "compiler.cfg.value-numbering.graph" "Value numbering expression graph"
"Makes value number graphs."
$nl
"Variables:"
{ $subsections
  exprs>vns
  vns>insns
  vregs>vns
} ;

ABOUT: "compiler.cfg.value-numbering.graph"
