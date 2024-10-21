! Copyright (C) 2010 Samuel Tardieu.
! See https://factorcode.org/license.txt for BSD license.
USING: assocs help.markup help.syntax math sequences ;
IN: path-finding

{ <astar> <bfs> <dijkstra> } related-words

HELP: astar
{ $description "This tuple must be subclassed and its method " { $link cost } ", "
  { $link heuristic } ", and " { $link neighbors } " must be implemented. "
  "Alternatively, the " { $link <astar> } " word can be used to build a non-specialized version." } ;

HELP: cost
{ $values
  { "from" "a node" }
  { "to" "a node" }
  { "astar" "an instance of a subclassed " { $link astar } " tuple" }
  { "n" number }
}
{ $description "Return the cost to go from " { $snippet "from" } " to " { $snippet "to" } ". "
  { $snippet "to" } " is necessarily a neighbor of " { $snippet "from" } "."
} ;

HELP: heuristic
{ $values
  { "from" "a node" }
  { "to" "a node" }
  { "astar" "an instance of a subclassed " { $link astar } " tuple" }
  { "n" number }
}
{ $description "Return the estimated (undervalued) cost to go from " { $snippet "from" } " to " { $snippet "to" } ". "
  { $snippet "from" } " and " { $snippet "to" } " are not necessarily neighbors."
} ;

HELP: neighbors
{ $values
  { "node" "a node" }
  { "astar" "an instance of a subclassed " { $link astar } " tuple" }
  { "seq" "a sequence of nodes" }
}
{ $description "Return the list of nodes reachable from " { $snippet "node" } "." } ;

HELP: <astar>
{ $values
  { "neighbors" { $quotation ( node -- seq ) } }
  { "cost" { $quotation ( from to -- cost ) } }
  { "heuristic" { $quotation ( pos target -- cost ) } }
  { "astar" astar }
}
{ $description "Build an astar object from the given quotations. The "
  { $snippet "neighbors" } " one builds the list of neighbors. The "
  { $snippet "cost" } " and " { $snippet "heuristic" } " ones represent "
  "respectively the cost for transitioning from a node to one of its neighbor, "
  "and the underestimated cost for going from a node to the target. This solution "
  "may not be as efficient as subclassing the " { $link astar } " tuple."
} ;

HELP: <bfs>
{ $values
  { "neighbors" assoc }
  { "astar" astar }
}
{ $description "Build an astar object from the " { $snippet "neighbors" } " assoc. "
  "When used with " { $link find-path } ", this astar tuple will use the breadth-first search (BFS) "
  "path finding algorithm which is a particular case of the general A* algorithm."
} ;

HELP: <dijkstra>
{ $values
  { "costs" assoc }
  { "astar" astar }
}
{ $description "Build an astar object from the " { $snippet "costs" } " assoc. "
  "The assoc keys are edges of the graph, while the corresponding values are assocs whose keys are "
  "the edges that can be reached and whose values are the costs to reach those edges. When used with "
  { $link find-path } ", this astar tuple will use the Dijkstra path finding algorithm which is "
  "a particular case of the general A* algorithm."
} ;

HELP: find-path
{ $values
  { "start" "a node" }
  { "target" "a node" }
  { "astar" astar }
  { "path/f" "an optimal path from " { $snippet "start" } " to " { $snippet "target" }
    ", or f if no such path exists" }
}
{ $description "Find a path between " { $snippet "start" } " and " { $snippet "target" }
  " using the A* algorithm."
} ;

HELP: find-path*
{ $values
  { "start" "a node" }
  { "quot" { $quotation ( node -- ? ) } }
  { "astar" astar }
  { "path/f" "an optimal path starting from " { $snippet "start" } ", or f if no such path exists" }
}
{ $description "Find a path starting from " { $snippet "start" } " using the A* algorithm. The end "
  "of the path has been found when " { $snippet "quot" } " returns a true value."
} ;

HELP: considered
{ $values
  { "astar" astar }
  { "considered" sequence }
}
{ $description "When called after a call to " { $link find-path } ", return a list of nodes "
  "which have been examined during the A* exploration."
} ;

ARTICLE: "path-finding" "Path finding using the A* algorithm"
"The " { $vocab-link "path-finding" } " vocabulary implements a graph search algorithm for finding the least-cost path from one node to another using the A* algorithm." $nl
"The " { $link astar } " tuple may be derived from and its " { $link cost } ", " { $link heuristic } ", and " { $link neighbors } " methods overwritten, or the " { $link <astar> } " or " { $link <bfs> } " words can be used to build a new tuple." $nl
"Make an A* object:"
{ $subsections <astar> <bfs> }
"Find a path between nodes:"
{ $subsections find-path } ;

ABOUT: "path-finding"
