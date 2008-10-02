! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax io.streams.string ;
IN: assoc-deques

HELP: <assoc-deque>
{ $description "Constructs a new " { $link assoc-deque } " from two existing data structures." } ;

HELP: <unique-max-heap>
{ $values
    
     { "unique-heap" assoc-deque } }
{ $description "Creates a new " { $link assoc-deque } " where the assoc is a hashtable and the deque is a max-heap." } ;

HELP: <unique-min-heap>
{ $values
    
     { "unique-heap" assoc-deque } }
{ $description "Creates a new " { $link assoc-deque } " where the assoc is a hashtable and the deque is a min-heap." } ;

HELP: assoc-deque
{ $description "A data structure containing an assoc and a deque to get certain properties with better time constraints at the expense of more space and complexity. For instance, a hashtable and a heap can be combined into one assoc-deque to get a sorted data structure with O(1) lookup. Operations on assoc-deques should update both the assoc and the deque." } ;

ARTICLE: "assoc-deques" "Associative deques"
"The " { $vocab-link "assoc-deques" } " vocabulary combines exists to synthesize data structures with better time properties than either of the two component data structures alone." $nl
"Associative deque constructor:"
{ $subsection <assoc-deque> }
"Unique heaps:"
{ $subsection <unique-min-heap> }
{ $subsection <unique-max-heap> } ;

ABOUT: "assoc-deques"
