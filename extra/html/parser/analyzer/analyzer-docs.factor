USING: help.syntax help.markup html.parser html.parser.analyzer
kernel sequences strings ;
IN: html.parser.analyzer

HELP: html-class?
{ $values { "tag" tag } { "string" "a classname" } { "?" boolean } }
{ $description "t if the tag has the given class." } ;

HELP: stack-find
{ $values { "seq" sequence } { "quot" { $quotation ( elt -- 1/0/-1 ) } } { "i/f" "an index or " { $link f } } }
{ $description "Takes a sequence and a quotation expected to return -1 if the element decrements the stack, 0 if it doesn't affect it and 1 if it increments it. Then finds the first element where the stack is empty." } ;

HELP: tag-classifier
{ $values { "string" string } { "quot" { $quotation ( elt -- 1/0/-1 ) } } }
{ $description "Builds a function that classifies tag tuples. Returns 1 if the tag is an opening tag with the given name, -1 if it is a closing tag and 0 otherwise." } ;
