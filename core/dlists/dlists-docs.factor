USING: help.markup help.syntax kernel quotations dlists.private ;
IN: dlists

ARTICLE: "dlists" "Doubly-linked lists"
"A doubly-linked list, or dlist, is a list of nodes. Each node has a link to the previous and next nodes, and a slot to store an object."
$nl
"While nodes can be modified directly, the fundamental protocol support by doubly-linked lists is that of a double-ended queue with a few additional operations. Elements can be added or removed at both ends of the dlist in constant time."
$nl
"When using a dlist as a simple queue, the convention is to queue elements with " { $link push-front } " and dequeue them with " { $link pop-back } "."
$nl
"Dlists form a class:"
{ $subsection dlist }
{ $subsection dlist? }
"Constructing a dlist:"
{ $subsection <dlist> }
"Working with the front of the list:"
{ $subsection push-front }
{ $subsection push-front* }
{ $subsection peek-front }
{ $subsection pop-front }
{ $subsection pop-front* }
"Working with the back of the list:"
{ $subsection push-back }
{ $subsection push-back* }
{ $subsection peek-back }
{ $subsection pop-back }
{ $subsection pop-back* }
"Finding out the length:"
{ $subsection dlist-empty? }
{ $subsection dlist-length }
"Iterating over elements:"
{ $subsection dlist-each }
{ $subsection dlist-find }
{ $subsection dlist-contains? }
"Deleting a node:"
{ $subsection delete-node }
{ $subsection dlist-delete }
"Deleting a node matching a predicate:"
{ $subsection delete-node-if* }
{ $subsection delete-node-if }
"Consuming all nodes:"
{ $subsection dlist-slurp } ;

ABOUT: "dlists"

HELP: dlist-empty?
{ $values { "dlist" { $link dlist } } { "?" "a boolean" } }
{ $description "Returns true if a " { $link dlist } " is empty." }
{ $notes "This operation is O(1)." } ;

HELP: push-front
{ $values { "obj" "an object" } { "dlist" dlist } }
{ $description "Push the object onto the front of the " { $link dlist } "." } 
{ $notes "This operation is O(1)." } ;

HELP: push-front*
{ $values { "obj" "an object" } { "dlist" dlist } { "dlist-node" dlist-node } }
{ $description "Push the object onto the front of the " { $link dlist } " and return the newly created " { $snippet "dlist-node" } "." } 
{ $notes "This operation is O(1)." } ;

HELP: push-back
{ $values { "obj" "an object" } { "dlist" dlist } }
{ $description "Push the object onto the back of the " { $link dlist } "." } 
{ $notes "This operation is O(1)." } ;

HELP: push-back*
{ $values { "obj" "an object" } { "dlist" dlist } { "dlist-node" dlist-node } }
{ $description "Push the object onto the back of the " { $link dlist } " and return the newly created " { $snippet "dlist-node" } "." } 
{ $notes "This operation is O(1)." } ;

HELP: peek-front
{ $values { "dlist" dlist } { "obj" "an object" } }
{ $description "Returns the object at the front of the " { $link dlist } "." } ;

HELP: pop-front
{ $values { "dlist" dlist } { "obj" "an object" } }
{ $description "Pop the object off the front of the " { $link dlist } " and return the object." }
{ $notes "This operation is O(1)." } ;

HELP: pop-front*
{ $values { "dlist" dlist } }
{ $description "Pop the object off the front of the " { $link dlist } "." }
{ $notes "This operation is O(1)." } ;

HELP: peek-back
{ $values { "dlist" dlist } { "obj" "an object" } }
{ $description "Returns the object at the back of the " { $link dlist } "." } ;

HELP: pop-back
{ $values { "dlist" dlist } { "obj" "an object" } }
{ $description "Pop the object off the back of the " { $link dlist } " and return the object." }
{ $notes "This operation is O(1)." } ;

HELP: pop-back*
{ $values { "dlist" dlist } }
{ $description "Pop the object off the back of the " { $link dlist } "." }
{ $notes "This operation is O(1)." } ;

{ push-front push-front* push-back push-back* peek-front pop-front pop-front* peek-back pop-back pop-back* } related-words

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
