! See http://factorcode.org/license.txt for BSD licence.
USING: help.markup help.syntax ;

IN: graph-theory

ARTICLE: "graph-protocol" "Graph protocol"
"All graphs must be instances of the graph mixin:"
{ $subsection graph }
"All graphs must implement a method on the following generic word:"
{ $subsection vertices }
"At least one of the following two generic words must have a method; the " { $link graph } " mixin has default definitions which are mutually recursive:"
{ $subsection adjlist }
{ $subsection adj? }
"All mutable graphs must implement a method on the following generic word:"
{ $subsection add-blank-vertex }
"All mutable undirected graphs must implement a method on the following generic word:"
{ $subsection add-edge }
"Mutable directed graphs should not implement the above word, as it has a default definition defined in terms of the following generic word:"
{ $subsection add-edge* }
"The following two words have default definitions, but are available as generics to allow implementations to optimize them:"
{ $subsection num-vertices }
{ $subsection num-edges } ;

HELP: graph
{ $class-description "A mixin class whose instances are graphs.  Custom implementations of the graph protocol should be declared as instances of this mixin for all graph functionality to work correctly:"
    { $code "INSTANCE: hex-board graph" }
} ;

{ vertices num-vertices num-edges } related-words

HELP: vertices
{ $values { "graph" graph } { "seq" "The vertices" } }
{ $description "Returns the vertices of the graph." } ;

HELP: num-vertices
{ $values { "graph" graph } { "n" "The number of vertices" } }
{ $description "Returns the number of vertices in the graph." } ;

HELP: num-edges
{ $values { "graph" "A graph" } { "n" "The number of edges" } }
{ $description "Returns the number of edges in the graph." } ;

{ adjlist adj? } related-words

HELP: adjlist
{ $values
    { "from" "The index of a vertex" }
    { "graph" "The graph to be examined" }
    { "seq" "The adjacency list" } }
{ $description "Returns a sequence of vertices that this vertex links to" } ;

HELP: adj?
{ $values
    { "from" "The index of a vertex" }
    { "to" "The index of a vertex" }
    { "graph" "A graph" }
    { "?" "A boolean" } }
{ $description "Returns a boolean describing whether there is an edge in the graph between from and to." } ;

{ add-blank-vertex add-blank-vertices add-edge add-edge* } related-words

HELP: add-blank-vertex
{ $values
    { "index" "A vertex index" }
    { "graph" "A graph" } }
{ $description "Adds a vertex to the graph." } ;

HELP: add-blank-vertices
{ $values
    { "seq" "A sequence of vertex indices" }
    { "graph" "A graph" } }
{ $description "Adds vertices with indices in seq to the graph." } ;

HELP: add-edge*
{ $values
    { "from" "The index of a vertex" }
    { "to" "The index of another vertex" }
    { "graph" "A graph" } }
{ $description "Adds a one-way edge to the graph, between " { $snippet "from" } " and " { $snippet "to" } "."
  $nl 
  "If you want to add a two-way edge, use " { $link add-edge } " instead." } ;

HELP: add-edge
{ $values
    { "u" "The index of a vertex" }
    { "v" "The index of another vertex" }
    { "graph" "A graph" } }
{ $description "Adds a two-way edge to the graph, between " { $snippet "u" } " and " { $snippet "v" } "."
  $nl
  "If you want to add a one-way edge, use " { $link add-edge* } " instead." } ;

{ depth-first full-depth-first dag? topological-sort } related-words

HELP: depth-first
{ $values
    { "v" "The vertex to start the search at" }
    { "graph" "The graph to search" }
    { "pre" "A quotation of the form ( n -- )" }
    { "post" "A quotation of the form ( n -- )" }
    { "?list" "A list of booleans describing the vertices visited in the search" }
    { "?" "A boolean describing whether or not the end-search error was thrown" } }
{ $description "Performs a depth-first search on " { $emphasis "graph" } ".  The variable " { $emphasis "graph" } " can be accessed in both quotations."
  $nl
  "The " { $emphasis "pre" } " quotation is run before the recursive application of depth-first."
  $nl
  "The " { $emphasis "post" } " quotation is run after the recursive application of depth-first."
  $nl
  { $emphasis "?list" } " is a list of booleans, " { $link t } " for every vertex visted during the search, and " { $link f } " for every vertex not visited." } ;

HELP: full-depth-first
{ $values
    { "graph" "The graph to search" }
    { "pre" "A quotation of the form ( n -- )" }
    { "post" "A quotation of the form ( n -- )" }
    { "tail" "A quotation of the form ( -- )" }
    { "?" "A boolean describing whether or not the end-search error was thrown" } }
{ $description "Performs a depth-first search on " { $emphasis "graph" } ".  The variable " { $emphasis "graph" } "can be accessed in both quotations."
  $nl
  "The " { $emphasis "pre" } " quotation is run before the recursive application of depth-first."
  $nl
  "The " { $emphasis "post" } " quotation is run after the recursive application of depth-first."
  $nl
  "The " { $emphasis "tail" } " quotation is run after each time the depth-first search runs out of nodes.  On an undirected graph this will be each connected subgroup but on a directed graph it can be more complex." } ;

HELP: dag?
{ $values
    { "graph" graph }
    { "?" "A boolean indicating if the graph is acyclic" } }
{ $description "Using a depth-first search, determines if the specified directed graph is a directed acyclic graph.  An undirected graph will produce a false result, as the algorithm does not eliminate cycles of length 2, which will include any edge that goes both ways." } ;

HELP: topological-sort
{ $values
    { "graph" graph }
    { "seq/f" "Either a sequence of values or f" } }
{ $description "Using a depth-first search, topologically sorts the specified directed graph.  Returns f if the graph contains any cycles, and a topologically sorted sequence otherwise." } ;
