USING: heaps.private help.markup help.syntax kernel ;
IN: heaps

ARTICLE: "heaps" "Heaps"
"A heap is a data structure that obeys the heap property.  A min-heap will always have its smallest member available, as a max-heap will its largest.  Objects stored on the heap must be comparable using the " { $link <=> } " operator, which may mean defining a new method on an object by using " { $link POSTPONE: M: } "."
;


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
