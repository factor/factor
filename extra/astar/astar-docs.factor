! Copyright (C) 2010 Samuel Tardieu.
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax ;
IN: astar

HELP: astar
{ $description "This tuple must be subclassed and its method " { $link cost } ", "
  { $link heuristic } ", and " { $link neighbours } " must be implemented. "
  "Alternatively, the " { $link <astar> } " word can be used to build a non-specialized version." } ;

HELP: cost
{ $values
  { "from" "a node" }
  { "to" "a node" }
  { "astar" "an instance of a subclassed " { $link astar } " tuple" }
  { "n" "a number" }
}
{ $description "Return the cost to go from " { $snippet "from" } " to " { $snippet "to" } ". "
  { $snippet "to" } " is necessarily a neighbour of " { $snippet "from" } "."
} ;

HELP: heuristic
{ $values
  { "from" "a node" }
  { "to" "a node" }
  { "astar" "an instance of a subclassed " { $link astar } " tuple" }
  { "n" "a number" }
}
{ $description "Return the estimated (undervalued) cost to go from " { $snippet "from" } " to " { $snippet "to" } ". "
  { $snippet "from" } " and " { $snippet "to" } " are not necessarily neighbours."
} ;

HELP: neighbours
{ $values
  { "node" "a node" }
  { "astar" "an instance of a subclassed " { $link astar } " tuple" }
  { "seq" "a sequence of nodes" }
}
{ $description "Return the list of nodes reachable from " { $snippet "node" } "." } ;

HELP: <astar>
{ $values
  { "neighbours" "a quotation with stack effect ( node -- seq )" }
  { "cost" "a quotation with stack effect ( from to -- cost )" }
  { "heuristic" "a quotation with stack effect ( pos target -- cost )" }
  { "astar" "a astar tuple" }
}
{ $description "Build an astar object from the given quotations. The "
  { $snippet "neighbours" } " one builds the list of neighbours. The "
  { $snippet "cost" } " and " { $snippet "heuristic" } " ones represent "
  "respectively the cost for transitioning from a node to one of its neighbour, "
  "and the underestimated cost for going from a node to the target. This solution "
  "may not be as efficient as subclassing the " { $link astar } " tuple."
} ;

HELP: find-path
{ $values
  { "start" "a node" }
  { "target" "a node" }
  { "astar" "a astar tuple" }
  { "path/f" "an optimal path from " { $snippet "start" } " to " { $snippet "target" }
    ", or f if no such path exists" }
}
{ $description "Find a path between " { $snippet "start" } " and " { $snippet "target" }
  " using the A* algorithm. The " { $snippet "astar" } " tuple must have been previously "
  " built using " { $link <astar> } "."
} ;

HELP: considered
{ $values
  { "astar" "a astar tuple" }
  { "considered" "a sequence" }
}
{ $description "When called after a call to " { $link find-path } ", return a list of nodes "
  "which have been examined during the A* exploration."
} ;

ARTICLE: "astar" "A* algorithm"
"The " { $vocab-link "astar" } " vocabulary implements a graph search algorithm for finding the least-cost path from one node to another." $nl
"Make an A* object:"
{ $subsections <astar> }
"Find a path between nodes:"
{ $subsections find-path } ;

ABOUT: "astar"
