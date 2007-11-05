USING: heaps.private help.markup help.syntax kernel ;
IN: heaps

ARTICLE: "heaps" "Heaps"
"A heap is an implementation of a " { $emphasis "priority queue" } ", which is a structure that maintains a sorted set of elements. The key property is that insertion of an arbitrary element and removal of the first element (determined by order) is performed in O(log n) time."
$nl
"Heap elements are compared using the " { $link <=> } " generic word."
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
;

HELP: <max-heap>
{ $values { "max-heap" max-heap } }
{ $description "Create a new " { $link max-heap } "." }
;

HELP: heap-push
{ $values { "obj" "an object" } { "heap" "a heap" } }
{ $description "Push an object onto a heap." } ; 

HELP: heap-push-all
{ $values { "seq" "a sequence" } { "heap" "a heap" } }
{ $description "Push a sequence onto a heap." } ; 

HELP: heap-peek
{ $values { "heap" "a heap" } { "obj" "an object" } }
{ $description "Returns the first element in the heap and leaves it in the heap." } ;

HELP: heap-pop*
{ $values { "heap" "a heap" } }
{ $description "Removes the first element from the heap." } ;

HELP: heap-pop
{ $values { "heap" "a heap" } { "obj" "an object" } }
{ $description "Returns the first element in the heap and removes it from the heap." } ;

HELP: heap-empty?
{ $values { "heap" "a heap" } { "?" "a boolean" } }
{ $description "Tests if a " { $link heap } " has no nodes." } ;
