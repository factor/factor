USING: assocs hashtables hash-sets help.markup help.syntax
kernel sequences sets ;
IN: graphs

ARTICLE: "graphs" "Directed graph utilities"
"Words for treating associative mappings as directed graphs can be found in the " { $vocab-link "graphs" } " vocabulary. A directed graph is represented as an assoc mapping each vertex to a " { $link hash-set } " of edges entering that vertex."
$nl
"To create a new graph, just create an assoc, for example by calling " { $link <hashtable> } ". To add vertices and edges to a graph:"
{ $subsections add-vertex }
"To remove vertices from the graph:"
{ $subsections remove-vertex }
"Since graphs are represented as assocs, they can be cleared out by calling " { $link clear-assoc } "."
$nl
"You can perform queries on a graph:"
{ $subsections closure }
"Directed graphs are used to maintain cross-referencing information for " { $link "definitions" } "." ;

ABOUT: "graphs"

HELP: add-vertex
{ $values { "vertex" object } { "edges" sequence } { "graph" "an " { $link assoc } " mapping vertices to " { $link hash-set } " of edges" } }
{ $description "Adds a vertex to a directed graph, with " { $snippet "edges" } " as the outward edges from the vertex." }
{ $side-effects "graph" } ;

HELP: remove-vertex
{ $values { "vertex" object } { "edges" sequence } { "graph" "an " { $link assoc } " mapping vertices to " { $link set } "s of edges" } }
{ $description "Removes a vertex from a graph, using the given edges sequence." }
{ $notes "The " { $snippet "edges" } " sequence must have all the values passed to " { $link add-vertex } ", otherwise some vertices of the graph may continue to refer to the removed vertex." }
{ $side-effects "graph" } ;

HELP: closure
{ $values { "vertex" object } { "quot" { $quotation ( vertex -- edges ) } } { "set" hash-set } }
{ $description "Outputs all vertices reachable from " { $snippet "vertex" } " via edges given by the quotation. The set always includes " { $snippet "vertex" } "." } ;
