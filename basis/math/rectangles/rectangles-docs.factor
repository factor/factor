USING: help.markup help.syntax kernel ;
IN: math.rectangles

HELP: rect
{ $class-description "A rectangle with the following slots:"
    { $slots
        { "loc" "the top-left corner of the rectangle as an x/y pair" }
        { "dim" "the dimensions of the rectangle as a width/height pair" }
    }
    "Rectangles are constructed by calling " { $link <rect> } " and " { $link <extent-rect> } "."
} ;

HELP: <rect>
{ $values { "loc" "a pair of integers" } { "dim" "a pair of integers" } { "rect" "a new " { $link rect } } }
{ $description "Creates a new rectangle with the specified top-left location and dimensions." } ;

{ <zero-rect> <rect> <extent-rect> } related-words

HELP: rect-bounds
{ $values { "rect" rect } { "loc" "a pair of integers" } { "dim" "a pair of integers" } }
{ $description "Outputs the location and dimensions of a rectangle." } ;

{ rect-bounds rect-extent } related-words

HELP: <extent-rect>
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

HELP: contains-rect?
{ $values { "rect1" rect } { "rect2" rect } { "?" boolean } }
{ $description "Tests if two rectangles have a non-empty intersection." } ;

HELP: contains-point?
{ $values { "point" "a pair of integers" } { "rect" rect } { "?" boolean } }
{ $description "Tests if a rectangle contains a point." } ;

HELP: <zero-rect>
{ $values { "rect" "a new " { $link rect } } }
{ $description "Creates a rectangle located at the origin with zero dimensions." } ;

ARTICLE: "math.rectangles" "Rectangles"
"The " { $vocab-link "math.rectangles" } " vocabulary defines a rectangle data type and operations on them."
{ $subsections rect }
"Rectangles can be taken apart:"
{ $subsections
    rect-bounds
    rect-extent
}
"New rectangles can be created:"
{ $subsections
    <zero-rect>
    <rect>
    <extent-rect>
}
"Set-theoretic operations on rectangles:"
{ $subsections
    rect-intersect
    rect-union
    contains-rect?
    contains-point?
}
"A utility word:"
{ $subsections offset-rect } ;

ABOUT: "math.rectangles"
