USING: arrays assocs help.markup help.syntax math.geometry.rect quadtrees quotations sequences ;
IN: quadtrees

ARTICLE: "quadtrees" "Quadtrees"
"The " { $snippet "quadtrees" } " vocabulary implements the quadtree structure in Factor. Quadtrees follow the " { $link "assocs-protocol" } " for insertion, deletion, and querying of exact points, using two-dimensional vectors as keys. Additional words are provided for spatial queries and pruning the tree structure:"
{ $subsection prune }
{ $subsection in-rect }
"The following words are provided to help write quadtree algorithms:"
{ $subsection descend }
{ $subsection each-quadrant }
{ $subsection map-quadrant } ;

ABOUT: "quadtrees"

HELP: prune
{ $values { "tree" quadtree } }
{ $description "Removes empty nodes from " { $snippet "tree" } "." } ;

HELP: in-rect
{ $values { "tree" quadtree } { "rect" rect } { "values" sequence } }
{ $description "Returns a " { $link sequence } " of values from " { $snippet "tree" } " whose keys lie inside " { $snippet "rect" } "." } ;

HELP: descend
{ $values { "pt" sequence } { "node" quadtree } { "subnode" quadtree } }
{ $description "Descends into the subnode of quadtree node " { $snippet "node" } " that contains " { $snippet "pt" } ", leaving " { $snippet "pt" } " on the stack." } ;

HELP: each-quadrant
{ $values { "node" quadtree } { "quot" quotation } }
{ $description "Calls " { $snippet "quot" } " with each subnode of " { $snippet "node" } " on the top of the stack in turn." } ;

HELP: map-quadrant
{ $values { "node" quadtree } { "quot" quotation } { "array" array } }
{ $description "Calls " { $snippet "quot" } " with each subnode of " { $snippet "node" } " on the top of the stack in turn, collecting the four results into " { $snippet "array" } "." } ;

