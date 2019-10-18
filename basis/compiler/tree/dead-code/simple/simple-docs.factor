USING: compiler.tree help.markup help.syntax kernel math sequences
strings ;
IN: compiler.tree.dead-code.simple

HELP: dead-flushable-call?
{ $values { "#call" #call } { "?" boolean } }
{ $description { $link t } " if the called word is flushable and none of its outputs are used." } ;

HELP: filter-corresponding
{ $values { "new" sequence } { "old" sequence } { "old'" sequence } }
{ $description "Remove elements from 'old' if the element with the same index in 'new' is dead." } ;

HELP: flushable-call?
{ $values { "#call" #call } { "?" "boolean" } }
{ $description { $link t } " if the call is flushable. To be flushable, two conditions must hold; first the word must have been declared flushable. Then, if it has any \"input-classes\" declared, all inputs to the word must fit within those classes. For example, if an input is a " { $link string } " and the declared input class is " { $link integer } ", it doesn't fit and the word is not flushable." } ;
