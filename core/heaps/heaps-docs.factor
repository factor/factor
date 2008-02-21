USING: heaps.private help.markup help.syntax kernel math assocs ;
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
{ $subsection max-heap }
{ $subsection max-heap? }
{ $subsection <max-heap> }
"Both obey a protocol."
$nl
"Queries:"
{ $subsection heap-empty? }
{ $subsection heap-length }
{ $subsection heap-peek }
"Insertion:"
{ $subsection heap-push }
{ $subsection heap-push* }
{ $subsection heap-push-all }
"Removal:"
{ $subsection heap-pop* }
{ $subsection heap-pop }
{ $subsection heap-delete } ;

ABOUT: "heaps"

HELP: <min-heap>
{ $values { "min-heap" min-heap } }
{ $description "Create a new " { $link min-heap } "." } ;

HELP: <max-heap>
{ $values { "max-heap" max-heap } }
{ $description "Create a new " { $link max-heap } "." } ;

HELP: heap-push
{ $values { "key" "a comparable object" } { "value" object } { "heap" heap } }
{ $description "Push a pair onto a heap. The key must be comparable with all other keys by the " { $link <=> } " generic word." }
{ $side-effects "heap" } ;

HELP: heap-push*
{ $values { "key" "a comparable object" } { "value" object } { "heap" heap } { "entry" entry } }
{ $description "Push a pair onto a heap, and output an entry which may later be passed to " { $link heap-delete } "." }
{ $side-effects "heap" } ;

HELP: heap-push-all
{ $values { "assoc" assoc } { "heap" heap } }
{ $description "Push every key/value pair of an assoc onto a heap." }
{ $side-effects "heap" } ;

HELP: heap-peek
{ $values { "heap" heap } { "key" object } { "value" object } }
{ $description "Output the first element in the heap, leaving it in the heap." } ;

HELP: heap-pop*
{ $values { "heap" heap } }
{ $description "Remove the first element from the heap." }
{ $side-effects "heap" } ;

HELP: heap-pop
{ $values { "heap" heap } { "key" object } { "value" object } }
{ $description "Output and remove the first element in the heap." }
{ $side-effects "heap" } ;

HELP: heap-empty?
{ $values { "heap" heap } { "?" "a boolean" } }
{ $description "Tests if a " { $link heap } " has no nodes." } ;

HELP: heap-size
{ $values { "heap" heap } { "n" integer } }
{ $description "Returns the number of key/value pairs in the heap." } ;

HELP: heap-delete
{ $values { "heap" heap } { "key" object } { "value" object } }
{ $description "Output and remove the first element in the heap." }
{ $side-effects "heap" } ;
