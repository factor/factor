USING: compiler.tree compiler.tree.propagation.info help.markup
help.syntax quotations sequences words ;
IN: compiler.tree.propagation.simple

HELP: call-outputs-quot
{ $values { "#call" #call } { "word" word } { "infos" sequence } }
{ $description "Calls the word's \"outputs\" " { $link quotation } " to determine the output sequence of value infos, given the input sequence." } ;

HELP: output-value-infos
{ $values { "#call" #call } { "word" word } { "infos" sequence } }
{ $description "Computes what the output value infos for a #call node should be." }
{ $see-also value-info-state } ;

ARTICLE: "compiler.tree.propagation.simple"
"Propagation for straight-line code"
"Propagation for straight-line code" ;

ABOUT: "compiler.tree.propagation.simple"
