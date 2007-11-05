USING: heaps.private help.markup help.syntax kernel math ;
IN: heaps

ARTICLE: "heaps" "Heaps"
"A heap is an implementation of a " { $emphasis "priority queue" } ", which is a structure that maintains a sorted set of elements. The key property is that insertion of an arbitrary element and removal of the first element (determined by order) is performed in O(log n) time."
$nl
"Heap elements are key/value pairs and are compared using the " { $link <=> } " generic word on the first element of the pair."
$nl
"There are two classes of heaps. Min-heaps sort their elements so that the minimum element is first:"
{ $subsection min-heap }
{ $subsection min-heap? }
{ $subsection <min-heap> }
"Max-heaps sort their elements so that the maximum element is first:"
{ $subsection min-heap }
{ $subsection min-heap? }
{ $subsection <min-heap> }
"Both obey a protocol."
$nl
"Queries:"
{ $subsection heap-empty? }
{ $subsection heap-length }
{ $subsection heap-peek }
"Insertion:"
{ $subsection heap-push }
{ $subsection heap-push-all }
"Removal:"
{ $subsection heap-pop* }
{ $subsection heap-pop } ;

ABOUT: "heaps"

HELP: <min-heap>
{ $values { "min-heap" min-heap } }
{ $description "Create a new " { $link min-heap } "." }
{ $see-also <max-heap> } ;

HELP: <max-heap>
{ $values { "max-heap" max-heap } }
{ $description "Create a new " { $link max-heap } "." }
{ $see-also <min-heap> } ;

HELP: heap-push
{ $values { "key" "a comparable object" } { "value" object } { "heap"  } }
{ $description "Push an pair onto a heap.  The key must be comparable with all other keys by the " { $link <=> } " generic word." }
{ $see-also heap-push-all heap-pop } ;

HELP: heap-push-all
{ $values { "seq" "a sequence of pairs" } { "heap"  } }
{ $description "Push a sequence of pairs onto a heap." }
{ $see-also heap-push heap-pop } ; 

HELP: heap-peek
{ $values { "heap"  } { "key" object } { "value" object } }
{ $description "Outputs the first element in the heap, leaving it in the heap." }
{ $see-also heap-pop heap-pop* } ;

HELP: heap-pop*
{ $values { "heap"  } }
{ $description "Removes the first element from the heap." }
{ $see-also heap-pop heap-push heap-peek } ;

HELP: heap-pop
{ $values { "heap"  } { "key" object } { "value" object } }
{ $description "Outputs the first element in the heap and removes it from the heap." }
{ $see-also heap-pop* heap-push heap-peek } ;

HELP: heap-empty?
{ $values { "heap"  } { "?" "a boolean" } }
{ $description "Tests if a " { $link heap } " has no nodes." }
{ $see-also heap-length heap-peek } ;

HELP: heap-length
{ $values { "heap"  } { "n" integer } }
{ $description "Returns the number of key/value pairs in the heap." }
{ $see-also heap-empty? } ;
