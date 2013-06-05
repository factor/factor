USING: help.syntax help.markup html.parser.analyzer sequences strings ;
IN: html.parser.analyzer-docs

HELP: stack-find
{ $values { "seq" sequence } { "quot" { $quotation "( elt -- 1/0/-1 )" } } }
{ $description "Takes a sequence and a quotation expected to return -1 if the element decrements the stack, 0 if it doesnt affect it and 1 if it increments it. Then finds the first element where the stack is empty." } ;

HELP: tag-classifier
{ $values { "string" string } }
{ $description "Builds a function that classifies tag tuples. Returns 1 if the tag is an opening tag with the given name, -1 if it is a closing tag and 0 otherwise." } ;

