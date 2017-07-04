USING: classes compiler.tree compiler.tree.propagation.info
help.markup help.syntax quotations sequences
stack-checker.dependencies words ;
IN: compiler.tree.propagation.simple

HELP: call-outputs-quot
{ $values { "#call" #call } { "word" word } { "infos" sequence } }
{ $description "Calls the word's \"outputs\" " { $link quotation } " to determine the output sequence of value infos, given the input sequence." } ;

HELP: output-value-infos
{ $values { "#call" #call } { "word" word } { "infos" sequence } }
{ $description "Computes what the output value infos for a #call node should be." }
{ $see-also value-info-state } ;

HELP: propagate-predicate
{ $values { "#call" #call } { "word" word } { "infos" sequence } }
{ $description "We need to force the caller word to recompile when the class is redefined, since now we're making assumptions but the class definition itself." } ;

ARTICLE: "compiler.tree.propagation.simple" "Propagation for straight-line code"
"Propagation for straight-line code" ;

ABOUT: "compiler.tree.propagation.simple"
