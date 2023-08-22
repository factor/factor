IN: unrolled-lists
USING: help.markup help.syntax hashtables search-deques dlists
deques unrolled-lists.private ;

HELP: unrolled-list
{ $class-description "The class of unrolled lists."
    $nl
    "All nodes in an unrolled list contain an array of 32 items. Nodes point to the previous"
    " node and next node, or " { $link f } " if they do not exist."
    { $slots
        { "front" { "The front " { $link node } " of the list or " { $link f } "." } }
        { "front-pos" { "The position of the front element of the list in " 
          { $snippet "front" } "." } }
        { "back" { "The back " { $link node } " of the list or " { $link f } "." } }
        { "back-pos" { "The position of the back element of the list in " 
          { $snippet "back" } "." } }
    }
    $nl
    "It is not recommended to modify any of these slots manually. Using the "
    { $link deque } " protocol provides safer operations."
} ;

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
