USING: arrays help.markup help.syntax math.rectangles quadtrees quotations sequences ;
IN: quadtrees

ARTICLE: "quadtrees" "Quadtrees"
"The " { $snippet "quadtrees" } " vocabulary implements the quadtree data structure in Factor."
{ $subsections <quadtree> }
"Quadtrees follow the " { $link "assocs-protocol" } " for insertion, deletion, and querying of exact points, using two-dimensional vectors as keys. Additional words are provided for spatial queries and pruning the tree structure:"
{ $subsections
    in-rect
    prune-quadtree
}
"The following words are provided to help write quadtree algorithms:"
{ $subsections
    descend
    each-quadrant
    map-quadrant
}
"Quadtrees can be used to \"swizzle\" a sequence to improve the locality of spatial data in memory:"
{ $subsections swizzle } ;

ABOUT: "quadtrees"

HELP: <quadtree>
{ $values { "bounds" rect } { "quadtree" quadtree } }
{ $description "Constructs an empty quadtree covering the axis-aligned rectangle indicated by " { $snippet "bounds" } ". All the keys of " { $snippet "quadtree" } " must be two-dimensional vectors lying inside " { $snippet "bounds" } "." } ;

HELP: prune-quadtree
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

HELP: swizzle
{ $values { "sequence" sequence } { "quot" quotation } { "sequence'" sequence } }
{ $description "Swizzles " { $snippet "sequence" } " based on the two-dimensional vector values returned by calling " { $snippet "quot" } " on each element of " { $snippet "sequence" } "." } ;
