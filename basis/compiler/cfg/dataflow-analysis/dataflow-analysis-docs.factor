USING: compiler.cfg help.markup help.syntax ;
IN: compiler.cfg.dataflow-analysis

<PRIVATE

HELP: run-dataflow-analysis
{ $values
  { "cfg" cfg }
  { "dfa" "a dataflow analysis symbol" }
  { "in-sets" "inputs" }
  { "out-sets" "outputs" }
}
{ $description "Runs the given dataflow analysis on the cfg." } ;

PRIVATE>

HELP: FORWARD-ANALYSIS:
{ $syntax "FORWARD-ANALYSIS: word" }
{ $values { "word" "name of the compiler pass" } }
{ $description "Syntax word for defining a forward analysis compiler pass." } ;

HELP: BACKWARD-ANALYSIS:
{ $syntax "BACKWARD-ANALYSIS: word" }
{ $values { "word" "name of the compiler pass" } }
{ $description "Syntax word for defining a backward analysis compiler pass." } ;
