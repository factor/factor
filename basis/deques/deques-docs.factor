IN: deques
USING: help.markup help.syntax kernel ;

ARTICLE: "deques" "Dequeues"
"A deque is a data structure with constant-time insertion and removal of elements at both ends. Dequeue operations are defined in the " { $vocab-link "deques" } " vocabulary."
$nl
"Dequeues must be instances of a mixin class:"
{ $subsection deque }
"Dequeues must implement a protocol."
$nl
"Querying the deque:"
{ $subsection peek-front }
{ $subsection peek-back }
{ $subsection deque-length }
{ $subsection deque-member? }
"Adding and removing elements:"
{ $subsection push-front* }
{ $subsection push-back* }
{ $subsection pop-front* }
{ $subsection pop-back* }
{ $subsection clear-deque }
"Working with node objects output by " { $link push-front* } " and " { $link push-back* } ":"
{ $subsection delete-node }
{ $subsection node-value }
"Utility operations built in terms of the above:"
{ $subsection deque-empty? }
{ $subsection push-front }
{ $subsection push-all-front }
{ $subsection push-back }
{ $subsection push-all-back }
{ $subsection pop-front }
{ $subsection pop-back }
{ $subsection slurp-deque }
"When using a deque as a queue, the convention is to queue elements with " { $link push-front } " and deque them with " { $link pop-back } "." ;

ABOUT: "deques"

HELP: deque-empty?
{ $values { "deque" { $link deque } } { "?" "a boolean" } }
{ $description "Returns true if a deque is empty." }
{ $notes "This operation is O(1)." } ;

HELP: push-front
{ $values { "obj" object } { "deque" deque } }
{ $description "Push the object onto the front of the deque." } 
{ $notes "This operation is O(1)." } ;

HELP: push-front*
{ $values { "obj" object } { "deque" deque } { "node" "a node" } }
{ $description "Push the object onto the front of the deque and return the newly created node." } 
{ $notes "This operation is O(1)." } ;

HELP: push-back
{ $values { "obj" object } { "deque" deque } }
{ $description "Push the object onto the back of the deque." } 
{ $notes "This operation is O(1)." } ;

HELP: push-back*
{ $values { "obj" object } { "deque" deque } { "node" "a node" } }
{ $description "Push the object onto the back of the deque and return the newly created node." } 
{ $notes "This operation is O(1)." } ;

HELP: peek-front
{ $values { "deque" deque } { "obj" object } }
{ $description "Returns the object at the front of the deque." } ;

HELP: pop-front
{ $values { "deque" deque } { "obj" object } }
{ $description "Pop the object off the front of the deque and return the object." }
{ $notes "This operation is O(1)." } ;

HELP: pop-front*
{ $values { "deque" deque } }
{ $description "Pop the object off the front of the deque." }
{ $notes "This operation is O(1)." } ;

HELP: peek-back
{ $values { "deque" deque } { "obj" object } }
{ $description "Returns the object at the back of the deque." } ;

HELP: pop-back
{ $values { "deque" deque } { "obj" object } }
{ $description "Pop the object off the back of the deque and return the object." }
{ $notes "This operation is O(1)." } ;

HELP: pop-back*
{ $values { "deque" deque } }
{ $description "Pop the object off the back of the deque." }
{ $notes "This operation is O(1)." } ;
