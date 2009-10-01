IN: unrolled-lists
USING: help.markup help.syntax hashtables search-deques dlists
deques ;

HELP: unrolled-list
{ $class-description "The class of unrolled lists." } ;

HELP: <unrolled-list>
{ $values { "list" unrolled-list } }
{ $description "Creates a new unrolled list." } ;

HELP: <hashed-unrolled-list>
{ $values { "search-deque" search-deque } }
{ $description "Creates a new " { $link search-deque } " backed by an " { $link unrolled-list } ", with a " { $link hashtable } " for fast membership tests." } ;

ARTICLE: "unrolled-lists" "Unrolled lists"
"The " { $vocab-link "unrolled-lists" } " vocabulary provides an implementation of the " { $link deque } " protocol with constant time insertion and removal at both ends, and lower memory overhead than a " { $link dlist } " due to packing 32 elements per every node. The one tradeoff is that unlike dlists, " { $link delete-node } " is not supported for unrolled lists."
{ $subsections
    unrolled-list
    <unrolled-list>
    <hashed-unrolled-list>
} ;

ABOUT: "unrolled-lists"
