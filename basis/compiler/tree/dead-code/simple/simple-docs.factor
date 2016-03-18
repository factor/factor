USING: compiler.tree help.markup help.syntax kernel sequences ;
IN: compiler.tree.dead-code.simple

HELP: dead-flushable-call?
{ $values { "#call" #call } { "?" boolean } }
{ $description { $link t } " if the called word is flushable and none of its outputs are used." } ;

HELP: filter-corresponding
{ $values { "new" sequence } { "old" sequence } { "old'" sequence } }
{ $description "Remove elements from 'old' if the element with the same index in 'new' is dead." } ;

HELP: flushable-call?
{ $values { "#call" #call } { "?" "boolean" } }
{ $description { $link t } " if the call is flushable" } ;
