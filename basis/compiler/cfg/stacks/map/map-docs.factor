USING: assocs compiler.cfg help.markup help.syntax ;
IN: compiler.cfg.stacks.map

HELP: trace-stack-state
{ $values { "cfg" cfg } { "assoc" assoc } }
{ $description "Outputs an assoc with the instruction numbers as keys and as values two tuples of the data and retain stacks shapes before that instruction. All instructions in the cfg gets numbered as a side-effect." } ;
