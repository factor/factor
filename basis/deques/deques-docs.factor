USING: help.markup help.syntax kernel math sequences
quotations ;
IN: deques

HELP: deque-empty?
{ $values { "deque" deque } { "?" "a boolean" } }
{ $contract "Returns true if a deque is empty." }
{ $notes "This operation is O(1)." } ;

HELP: clear-deque
{ $values
     { "deque" deque } }
{ $description "Removes all elements from a deque." } ;

HELP: deque-member?
{ $values
     { "value" object } { "deque" deque }
     { "?" "a boolean" } }
{ $description "Returns true if the " { $snippet "value" } " is found in the deque." } ;

HELP: push-front
{ $values { "obj" object } { "deque" deque } }
{ $description "Push the object onto the front of the deque." } 
{ $notes "This operation is O(1)." } ;

HELP: push-front*
{ $values { "obj" object } { "deque" deque } { "node" "a node" } }
{ $contract "Push the object onto the front of the deque and return the newly created node." } 
{ $notes "This operation is O(1)." } ;

HELP: push-back
{ $values { "obj" object } { "deque" deque } }
{ $description "Push the object onto the back of the deque." } 
{ $notes "This operation is O(1)." } ;

HELP: push-back*
{ $values { "obj" object } { "deque" deque } { "node" "a node" } }
{ $contract "Push the object onto the back of the deque and return the newly created node." } 
{ $notes "This operation is O(1)." } ;

HELP: push-all-back
{ $values
     { "seq" sequence } { "deque" deque } }
{ $description "Pushes a sequence of elements onto the back of a deque." } ;

HELP: push-all-front
{ $values
     { "seq" sequence } { "deque" deque } }
{ $description "Pushes a sequence of elements onto the front of a deque." } ;

HELP: peek-front
{ $values { "deque" deque } { "obj" object } }
{ $contract "Returns the object at the front of the deque." } ;

HELP: pop-front
{ $values { "deque" deque } { "obj" object } }
{ $description "Pop the object off the front of the deque and return the object." }
{ $notes "This operation is O(1)." } ;

HELP: pop-front*
{ $values { "deque" deque } }
{ $contract "Pop the object off the front of the deque." }
{ $notes "This operation is O(1)." } ;

HELP: peek-back
{ $values { "deque" deque } { "obj" object } }
{ $contract "Returns the object at the back of the deque." } ;

HELP: pop-back
{ $values { "deque" deque } { "obj" object } }
{ $description "Pop the object off the back of the deque and return the object." }
{ $notes "This operation is O(1)." } ;

HELP: pop-back*
{ $values { "deque" deque } }
{ $contract "Pop the object off the back of the deque." }
{ $notes "This operation is O(1)." } ;

HELP: delete-node
{ $values
     { "node" object } { "deque" deque } }
{ $contract "Deletes the node from the deque." } ;

HELP: deque
{ $description "A data structure that has constant-time insertion and removal of elements at both ends." } ;

HELP: node-value
{ $values
     { "node" object }
     { "value" object } }
{ $description "Accesses the value stored at a node." } ;

HELP: slurp-deque
{ $values
     { "deque" deque } { "quot" quotation } }
{ $description "Pops off the back element of the deque and calls the quotation in a loop until the deque is empty." } ;

ARTICLE: "deques" "Deques"
"The " { $vocab-link "deques" } " vocabulary implements the deque data structure which has constant-time insertion and removal of elements at both ends."
$nl
"Deques must be instances of a mixin class:"
{ $subsections deque }
"Deques must implement a protocol."
$nl
"Querying the deque:"
{ $subsections
    peek-front
    peek-back
    deque-empty?
    deque-member?
}
"Adding and removing elements:"
{ $subsections
    push-front*
    push-back*
    pop-front*
    pop-back*
    clear-deque
}
"Working with node objects output by " { $link push-front* } " and " { $link push-back* } ":"
{ $subsections
    delete-node
    node-value
}
"Utility operations built in terms of the above:"
{ $subsections
    push-front
    push-all-front
    push-back
    push-all-back
    pop-front
    pop-back
    slurp-deque
}
"When using a deque as a queue, the convention is to queue elements with " { $link push-front } " and deque them with " { $link pop-back } "." ;

ABOUT: "deques"
