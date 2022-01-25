USING: classes compiler.cfg compiler.cfg.dataflow-analysis
compiler.cfg.dataflow-analysis.private help.markup help.syntax sequences ;

HELP: predecessors
{ $values { "bb" basic-block } { "dfa" "a dataflow analysis symbol" } { "seq" sequence } }
{ $description "Generic word that returns the predecessors for a block. It's purpose is to facilitate backward analysis in which the blocks successors are seen as the predecessors." } ;

HELP: successors
{ $values { "bb" basic-block } { "dfa" "a dataflow analysis symbol" } { "seq" sequence } }
{ $description "Generic word that returns the successors for a block. It's purpose is to facilitate backward analysis in which the blocks predecessors are seen as the successors." } ;

HELP: transfer-set
{ $values
  { "in-set" "input state" }
  { "bb" basic-block }
  { "dfa" class }
  { "out-set" "output state" }
}
{ $description "Generic word which is called during the dataflow analysis to process each basic block in the cfg. It is supposed to be implemented by all forward and backward dataflow analysis subclasses to perform analysis." } ;

HELP: join-sets
{ $values
  { "sets" "input states" }
  { "bb" basic-block }
  { "dfa" class }
  { "set" "merged state" }
}
{ $description "Generic word which merges multiple states into one. A block in the cfg might have multiple predecessors and then this word is used to compute the merged input state to use to analyze the block." }
{ $see-also transfer-set } ;


HELP: run-dataflow-analysis
{ $values
  { "cfg" cfg }
  { "dfa" "a dataflow analysis symbol" }
  { "in-sets" "inputs" }
  { "out-sets" "outputs" }
}
{ $description "Runs the given dataflow analysis on the cfg." } ;

HELP: FORWARD-ANALYSIS:
{ $syntax "FORWARD-ANALYSIS: word" }
{ $values { "word" "name of the compiler pass" } }
{ $description "Syntax word for defining a forward analysis compiler pass." } ;

HELP: BACKWARD-ANALYSIS:
{ $syntax "BACKWARD-ANALYSIS: word" }
{ $values { "word" "name of the compiler pass" } }
{ $description "Syntax word for defining a backward analysis compiler pass." } ;
