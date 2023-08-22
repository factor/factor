USING: help.syntax help.markup kernel arrays assocs ;
IN: persistent.heaps

HELP: <persistent-heap>
{ $values { "heap" "a persistent heap" } }
{ $description "Creates a new persistent heap" } ;

HELP: <singleton-heap>
{ $values { "value" object } { "prio" "a priority" } { "heap" "a persistent heap" } }
{ $description "Creates a new persistent heap consisting of one object with the given priority." } ;

HELP: pheap-empty?
{ $values { "heap" "a persistent heap" } { "?" boolean } }
{ $description "Returns true if this is an empty persistent heap." } ;

HELP: pheap-peek
{ $values { "heap" "a persistent heap" } { "value" "an object in the heap" } { "prio" "the minimum priority" } }
{ $description "Gets the object in the heap with minimum priority." } ;

HELP: pheap-push
{ $values { "value" object } { "prio" "a priority" } { "heap" "a persistent heap" } { "newheap" "a new persistent heap" } }
{ $description "Creates a new persistent heap also containing the given object of the given priority." } ;

HELP: pheap-pop*
{ $values { "heap" "a persistent heap" } { "newheap" "a new persistent heap" } }
{ $description "Creates a new persistent heap with the minimum element removed." } ;

HELP: pheap-pop
{ $values { "heap" "a persistent heap" } { "newheap" "a new persistent heap" } { "value" object } { "prio" "a priority" } }
{ $description "Creates a new persistent heap with the minimum element removed, returning that element and its priority." } ;

HELP: assoc>pheap
{ $values { "assoc" assoc } { "heap" "a persistent heap" } }
{ $description "Creates a new persistent heap from an associative mapping whose keys are the entries in the heap and whose values are the associated priorities." } ;

HELP: pheap>alist
{ $values { "heap" "a persistent heap" } { "alist" "an association list" } }
{ $description "Creates an association list whose keys are the entries in the heap and whose values are the associated priorities. It is in sorted order by priority. This does not modify the heap." } ;

HELP: pheap>values
{ $values { "heap" "a persistent heap" } { "seq" array } }
{ $description "Creates an an array of all of the values in the heap, in sorted order by priority. This does not modify the heap." } ;

ARTICLE: "persistent-heaps" "Persistent heaps"
"This vocabulary implements persistent minheaps, aka priority queues. They are purely functional and support efficient O(log n) operations of pushing and popping, with O(1) time access to the minimum element. To create heaps, use the following words:"
{ $subsections
    <persistent-heap>
    <singleton-heap>
}
"To manipulate them:"
{ $subsections
    pheap-peek
    pheap-push
    pheap-pop
    pheap-pop*
    pheap-empty?
    assoc>pheap
    pheap>alist
    pheap>values
} ;

ABOUT: "persistent-heaps"
