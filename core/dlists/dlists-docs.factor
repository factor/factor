USING: help.markup help.syntax kernel ;
IN: dlists

ARTICLE: "dlists" "Doubly-linked lists"
"A doubly-linked list is a list of nodes.  Each node has a link to the previous and next nodes, and a slot to store an object.  Objects can be pushed and popped from the front and back of the list.  The linked list keeps track of its length, so finding the length is O(1)."
;

HELP: dlist-empty?
{ $values { "dlist" { $link dlist } } { "?" "a boolean" } }
{ $description "Returns true if a " { $link dlist } " is empty." }
{ $notes "This operation is O(1)." } ;

HELP: push-front
{ $values { "obj" "an object" } { "dlist" dlist } }
{ $description "Push the object onto the front of the " { $link dlist } "." } 
{ $notes "This operation is O(1)." }
{ $see-also push-back pop-front pop-front* pop-back pop-back* } ;

HELP: push-back
{ $values { "obj" "an object" } { "dlist" dlist } }
{ $description "Push the object onto the back of the " { $link dlist } "." } 
{ $notes "This operation is O(1)." }
{ $see-also push-front pop-front pop-front* pop-back pop-back* } ;

HELP: pop-front
{ $values { "dlist" dlist } { "obj" "an object" } }
{ $description "Pop the object off the front of the " { $link dlist } " and return the object." }
{ $notes "This operation is O(1)." }
{ $see-also push-front push-back pop-front* pop-back pop-back* } ;

HELP: pop-front*
{ $values { "dlist" dlist } }
{ $description "Pop the object off the front of the " { $link dlist } "." }
{ $notes "This operation is O(1)." }
{ $see-also push-front push-back pop-front pop-back pop-back* } ;

HELP: pop-back
{ $values { "dlist" dlist } { "obj" "an object" } }
{ $description "Pop the object off the back of the " { $link dlist } " and return the object." }
{ $notes "This operation is O(1)." }
{ $see-also push-front push-back pop-front pop-front* pop-back* } ;

HELP: pop-back*
{ $values { "dlist" dlist } }
{ $description "Pop the object off the back of the " { $link dlist } "." }
{ $notes "This operation is O(1)." }
{ $see-also push-front push-back pop-front pop-front* pop-back } ;

HELP: dlist-find
{ $values { "quot" "a quotation" } { "dlist" { $link dlist } } { "obj/f" "an object or " { $link f } } { "?" "a boolean" } }
{ $description "Applies the quotation to each element of the " { $link dlist } " in turn, until it outputs a true value or the end of the " { $link dlist } " is reached.  Outputs either the object it found or " { $link f } ", and a boolean which is true if an object is found." }
{ $notes "Returns a boolean to allow dlists to store " { $link f } "."
    $nl
    "This operation is O(n)."
} ;

HELP: dlist-contains?
{ $values { "quot" "a quotation" } { "dlist" { $link dlist } } { "?" "a boolean" } }
{ $description "Just like " { $link dlist-find } " except it doesn't return the object." }
{ $notes "This operation is O(n)." } ;

HELP: delete-node*
{ $values { "quot" "a quotation" } { "dlist" { $link dlist } } { "obj/f" "an object or " { $link f } } { "?" "a boolean" } }
{ $description "Calls " { $link dlist-find } " on the " { $link dlist } " and deletes the node returned, if any.  Returns the value of the deleted node and a boolean to allow the deleted value to distinguished from " { $link f } ", for nothing deleted." }
{ $notes "This operation is O(n)." } ;

HELP: delete-node
{ $values { "quot" "a quotation" } { "dlist" { $link dlist } } { "obj/f" "an object or " { $link f } } }
{ $description "Like " { $link delete-node* } " but cannot distinguish from deleting a node whose value is " { $link f } " or not deleting an element." }
{ $notes "This operation is O(n)." } ;

HELP: dlist-each
{ $values { "quot" "a quotation" } { "dlist" { $link dlist } } }
{ $description "Iterate a " { $link dlist } ", calling quot on each element." } ;
