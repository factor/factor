USING: assocs dlists help.markup help.syntax mirrors ;
IN: dlists.mirrors

HELP: dlist-mirror
{ $class-description "An associative view of a doubly linked list's entries, keyed by zero-based position. Reading reflects the current list contents. Updating an existing key changes the corresponding node's value; deleting a key removes that node. Clearing the mirror empties the original list." }
{ $notes "This extension is loaded when both " { $vocab-link "dlists" } " and " { $vocab-link "mirrors" } " are loaded. To inspect the list's internal front and back links instead, call " { $link <mirror> } " explicitly." } ;

HELP: <dlist-mirror>
{ $values { "object" dlist } { "dlist-mirror" dlist-mirror } }
{ $description "Creates a mirror of the list's entries. " { $link make-mirror } " calls this word for a " { $link dlist } "." } ;
