IN: dequeues
USING: help.markup help.syntax kernel ;

ARTICLE: "dequeues" "Dequeues"
"A dequeue is a data structure with constant-time insertion and removal of elements at both ends. Dequeue operations are defined in the " { $vocab-link "dequeues" } " vocabulary."
$nl
"Dequeues must be instances of a mixin class:"
{ $subsection dequeue }
"Dequeues must implement a protocol."
$nl
"Querying the dequeue:"
{ $subsection peek-front }
{ $subsection peek-back }
{ $subsection dequeue-length }
{ $subsection dequeue-member? }
"Adding and removing elements:"
{ $subsection push-front* }
{ $subsection push-back* }
{ $subsection pop-front* }
{ $subsection pop-back* }
{ $subsection clear-dequeue }
"Working with node objects output by " { $link push-front* } " and " { $link push-back* } ":"
{ $subsection delete-node }
{ $subsection node-value }
"Utility operations built in terms of the above:"
{ $subsection dequeue-empty? }
{ $subsection push-front }
{ $subsection push-all-front }
{ $subsection push-back }
{ $subsection push-all-back }
{ $subsection pop-front }
{ $subsection pop-back }
{ $subsection slurp-dequeue }
"When using a dequeue as a queue, the convention is to queue elements with " { $link push-front } " and dequeue them with " { $link pop-back } "." ;

ABOUT: "dequeues"

HELP: dequeue-empty?
{ $values { "dequeue" { $link dequeue } } { "?" "a boolean" } }
{ $description "Returns true if a dequeue is empty." }
{ $notes "This operation is O(1)." } ;

HELP: push-front
{ $values { "obj" object } { "dequeue" dequeue } }
{ $description "Push the object onto the front of the dequeue." } 
{ $notes "This operation is O(1)." } ;

HELP: push-front*
{ $values { "obj" object } { "dequeue" dequeue } { "node" "a node" } }
{ $description "Push the object onto the front of the dequeue and return the newly created node." } 
{ $notes "This operation is O(1)." } ;

HELP: push-back
{ $values { "obj" object } { "dequeue" dequeue } }
{ $description "Push the object onto the back of the dequeue." } 
{ $notes "This operation is O(1)." } ;

HELP: push-back*
{ $values { "obj" object } { "dequeue" dequeue } { "node" "a node" } }
{ $description "Push the object onto the back of the dequeue and return the newly created node." } 
{ $notes "This operation is O(1)." } ;

HELP: peek-front
{ $values { "dequeue" dequeue } { "obj" object } }
{ $description "Returns the object at the front of the dequeue." } ;

HELP: pop-front
{ $values { "dequeue" dequeue } { "obj" object } }
{ $description "Pop the object off the front of the dequeue and return the object." }
{ $notes "This operation is O(1)." } ;

HELP: pop-front*
{ $values { "dequeue" dequeue } }
{ $description "Pop the object off the front of the dequeue." }
{ $notes "This operation is O(1)." } ;

HELP: peek-back
{ $values { "dequeue" dequeue } { "obj" object } }
{ $description "Returns the object at the back of the dequeue." } ;

HELP: pop-back
{ $values { "dequeue" dequeue } { "obj" object } }
{ $description "Pop the object off the back of the dequeue and return the object." }
{ $notes "This operation is O(1)." } ;

HELP: pop-back*
{ $values { "dequeue" dequeue } }
{ $description "Pop the object off the back of the dequeue." }
{ $notes "This operation is O(1)." } ;
