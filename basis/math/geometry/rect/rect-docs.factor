USING: help.markup help.syntax ;

IN: math.geometry.rect

HELP: rect
{ $class-description "A rectangle with the following slots:"
    { $list
        { { $link rect-loc } " - the top-left corner of the rectangle as an x/y pair" }
        { { $link rect-dim } " - the dimensions of the rectangle as a width/height pair" }
    }
    "Rectangles are constructed by calling " { $link <rect> } " and " { $link <extent-rect> } "."
} ;

HELP: <rect> ( loc dim -- rect )
{ $values { "loc" "a pair of integers" } { "dim" "a pair of integers" } { "rect" "a new " { $link rect } } }
{ $description "Creates a new rectangle with the specified top-left location and dimensions." } ;

{ <zero-rect> <rect> <extent-rect> } related-words

HELP: set-rect-dim ( dim rect -- )
{ $values { "dim" "a pair of integers" } { "rect" rect } }
{ $description "Modifies the dimensions of a rectangle." }
{ $side-effects "rect" } ;

HELP: rect-bounds
{ $values { "rect" rect } { "loc" "a pair of integers" } { "dim" "a pair of integers" } }
{ $description "Outputs the location and dimensions of a rectangle." } ;

{ rect-bounds rect-extent } related-words

HELP: <extent-rect> ( loc ext -- rect )
{ $values { "loc" "a pair of integers" } { "ext" "a pair of integers" } { "rect" "a new " { $link rect } } }
{ $description "Creates a new rectangle with the specified top-left and bottom-right corner locations." } ;

HELP: rect-extent
{ $values { "rect" rect } { "loc" "a pair of integers" } { "ext" "a pair of integers" } }
{ $description "Outputs the location of the top-left and bottom-right corners of a rectangle." } ;

HELP: offset-rect
{ $values { "rect" rect } { "loc" "a pair of integers" } { "newrect" "a new " { $link rect } } }
{ $description "Creates a new rectangle with the same dimensions, and top-left corner translated by " { $snippet "loc" } "." } ;

HELP: rect-intersect
{ $values { "rect1" rect } { "rect2" rect } { "newrect" "a new " { $link rect } } }
{ $description "Computes the intersection of two rectangles." } ;

HELP: intersects?
{ $values { "rect/point" "a " { $link rect } " or a pair of integers" } { "rect" rect } { "?" "a boolean" } }
{ $description "Tests if two rectangles (or a point and a rectangle, respectively) have a non-empty intersection." } ;

HELP: <zero-rect>
{ $values { "rect" "a new " { $link rect } } }
{ $description "Creates a rectangle located at the origin with zero dimensions." } ;

