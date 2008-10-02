! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax io.streams.string ;
IN: assoc-heaps

HELP: <assoc-heap>
{ $description "Constructs a new " { $link assoc-heap } " from two existing data structures." } ;

HELP: <unique-max-heap>
{ $values
    
     { "unique-heap" assoc-heap } }
{ $description "Creates a new " { $link assoc-heap } " where the assoc is a hashtable and the heap is a max-heap." } ;

HELP: <unique-min-heap>
{ $values
    
     { "unique-heap" assoc-heap } }
{ $description "Creates a new " { $link assoc-heap } " where the assoc is a hashtable and the heap is a min-heap." } ;

HELP: assoc-heap
{ $description "A data structure containing an assoc and a heap to get certain properties with better time constraints at the expense of more space and complexity. For instance, a hashtable and a heap can be combined into one assoc-heap to get a sorted data structure with O(1) lookup. Operations on assoc-heap should update both the assoc and the heap." } ;

ARTICLE: "assoc-heaps" "Associative heaps"
"The " { $vocab-link "assoc-heaps" } " vocabulary combines exists to synthesize data structures with better time properties than either of the two component data structures alone." $nl
"Associative heap constructor:"
{ $subsection <assoc-heap> }
"Unique heaps:"
{ $subsection <unique-min-heap> }
{ $subsection <unique-max-heap> } ;

ABOUT: "assoc-heaps"
