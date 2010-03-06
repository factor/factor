! Copyright (C) 2010 Samuel Tardieu.
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax ;
IN: astar

{ find-path <astar> considered } related-words

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
  "and the underestimated cost for going from a node to the target."
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
