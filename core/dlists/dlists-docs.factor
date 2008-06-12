USING: help.markup help.syntax kernel quotations
dequeues ;
IN: dlists

ARTICLE: "dlists" "Double-linked lists"
"A double-linked list is the canonical implementation of a " { $link dequeue } "."
$nl
"Double-linked lists form a class:"
{ $subsection dlist }
{ $subsection dlist? }
"Constructing a double-linked list:"
{ $subsection <dlist> }
"Double-linked lists support all the operations of the dequeue protocol (" { $link "dequeues" } ") as well as the following."
$nl
"Iterating over elements:"
{ $subsection dlist-each }
{ $subsection dlist-find }
{ $subsection dlist-contains? }
"Deleting a node matching a predicate:"
{ $subsection delete-node-if* }
{ $subsection delete-node-if } ;

ABOUT: "dlists"

HELP: dlist-find
{ $values { "dlist" { $link dlist } } { "quot" quotation } { "obj/f" "an object or " { $link f } } { "?" "a boolean" } }
{ $description "Applies the quotation to each element of the " { $link dlist } " in turn, until it outputs a true value or the end of the " { $link dlist } " is reached.  Outputs either the object it found or " { $link f } ", and a boolean which is true if an object is found." }
{ $notes "Returns a boolean to allow dlists to store " { $link f } "."
    $nl
    "This operation is O(n)."
} ;

HELP: dlist-contains?
{ $values { "dlist" { $link dlist } } { "quot" quotation } { "?" "a boolean" } }
{ $description "Just like " { $link dlist-find } " except it doesn't return the object." }
{ $notes "This operation is O(n)." } ;

HELP: delete-node-if*
{ $values { "dlist" { $link dlist } } { "quot" quotation } { "obj/f" "an object or " { $link f } } { "?" "a boolean" } }
{ $description "Calls " { $link dlist-find } " on the " { $link dlist } " and deletes the node returned, if any.  Returns the value of the deleted node and a boolean to allow the deleted value to distinguished from " { $link f } ", for nothing deleted." }
{ $notes "This operation is O(n)." } ;

HELP: delete-node-if
{ $values { "dlist" { $link dlist } } { "quot" quotation } { "obj/f" "an object or " { $link f } } }
{ $description "Like " { $link delete-node-if* } " but cannot distinguish from deleting a node whose value is " { $link f } " or not deleting an element." }
{ $notes "This operation is O(n)." } ;

HELP: dlist-each
{ $values { "dlist" { $link dlist } } { "quot" quotation } }
{ $description "Iterate a " { $link dlist } ", calling quot on each element." } ;
