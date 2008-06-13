IN: search-dequeues
USING: help.markup help.syntax kernel dlists hashtables
dequeues assocs ;

ARTICLE: "search-dequeues" "Search dequeues"
"A search dequeue is a data structure with constant-time insertion and removal of elements at both ends, and constant-time membership tests. Inserting an element more than once has no effect. Search dequeues implement all dequeue operations in terms of an underlying dequeue, and membership testing with " { $link dequeue-member? } " is implemented with an underlying assoc. Search dequeues are defined in the " { $vocab-link "search-dequeues" } " vocabulary."
$nl
"Creating a search dequeue:"
{ $subsection <search-dequeue> }
"Default implementation:"
{ $subsection <hashed-dlist> } ;

ABOUT: "search-dequeues"

HELP: <search-dequeue> ( assoc dequeue -- search-dequeue )
{ $values { "assoc" assoc } { "dequeue" dequeue } { "search-dequeue" search-dequeue } }
{ $description "Creates a new " { $link search-dequeue } "." } ;

HELP: <hashed-dlist> ( -- search-dequeue )
{ $values { "search-dequeue" search-dequeue } }
{ $description "Creates a new " { $link search-dequeue } " backed by a " { $link dlist } ", with a " { $link hashtable } " for fast membership tests." } ;
