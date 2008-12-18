! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax io.streams.string assocs
heaps.private ;
IN: assoc-heaps

HELP: <assoc-heap>
{ $values { "assoc" assoc } { "heap" heap } { "assoc-heap" assoc-heap } }
{ $description "Constructs a new " { $link assoc-heap } " from two existing data structures." } ;

HELP: <unique-max-heap>
{ $values { "unique-heap" assoc-heap } }
{ $description "Creates a new " { $link assoc-heap } " where the assoc is a hashtable and the heap is a max-heap. Popping an element from the heap leaves this element in the hashtable to ensure that the element will not be processed again." } ;

HELP: <unique-min-heap>
{ $values { "unique-heap" assoc-heap } }
{ $description "Creates a new " { $link assoc-heap } " where the assoc is a hashtable and the heap is a min-heap. Popping an element from the heap leaves this element in the hashtable to ensure that the element will not be processed again." } ;

{ <unique-max-heap> <unique-min-heap> } related-words

HELP: assoc-heap
{ $description "A data structure containing an assoc and a heap to get certain properties with better time constraints at the expense of more space and complexity. For instance, a hashtable and a heap can be combined into one assoc-heap to get a sorted data structure with O(1) lookup. Operations on assoc-heap may update both the assoc and the heap or leave them out of sync if it's advantageous." } ;

ARTICLE: "assoc-heaps" "Associative heaps"
"The " { $vocab-link "assoc-heaps" } " vocabulary combines exists to synthesize data structures with better time properties than either of the two component data structures alone." $nl
"Associative heap constructor:"
{ $subsection <assoc-heap> }
"Unique heaps:"
{ $subsection <unique-min-heap> }
{ $subsection <unique-max-heap> } ;

ABOUT: "assoc-heaps"
