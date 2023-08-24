! Copyright (C) 2017 Alexander Ilin.
! See https://factorcode.org/license.txt for BSD license.
USING: binary-search colors help.markup help.syntax kernel
sequences splitting.monotonic ui.gadgets ui.gadgets.charts
ui.gadgets.charts.lines.private ui.render ;
IN: ui.gadgets.charts.lines

ABOUT: { "ui.gadgets.charts.lines" "about" }

ARTICLE: { "ui.gadgets.charts.lines" "about" } "Lines"
" The " { $vocab-link "ui.gadgets.charts.lines" } " vocab implements the " { $link line } " gadget. See the " { $link { "charts.lines" "implementation" } } "." ;

ARTICLE: { "charts.lines" "implementation" } "Implementation details"
"The " { $slot "data" } " in a " { $link line } " gadget should be sorted by non-descending " { $snippet "x" } " coordinate. In a large data set this allows to quickly find the left and right intersection points with the viewport using binary " { $link search } " and remove the irrelevant data from further processing: " { $link clip-by-x } ". If the resulting sequence is empty (i.e. the entire data set is completely to the left or to the right of the viewport), nothing is drawn (" { $link x-in-bounds? } ")."
$nl
"If there are several points with the same " { $snippet "x" } " coordinate matching " { $snippet "xmin" } ", the leftmost of those is found and included in the resulting set (" { $link adjusted-head-slice } "). The same adjustment is done for the right point if it matches " { $snippet "xmax" } ", only this time the rightmost is searched for (" { $link adjusted-tail-slice } ")."
$nl
"If there are no points with either the " { $snippet "xmin" } " or the " { $snippet "xmax" } " coordinate, and the line spans beyond the viewport in either of those directions, the corresponding points are calculated and added to the data set (" { $link min-max-cut } ")."
$nl
"After we've got a subset of data that's completely within the " { $snippet "[xmin,xmax]" } " bounds, we check if the resulting data are completely above or completely below the viewport (" { $link y-in-bounds? } "), and if so, nothing is drawn. This involves finding the minimum and maximum " { $snippet "y" } " values by traversing the remaining data, which is why it's important to cut away the irrelevant data first and to make sure the " { $snippet "y" } " coordinates for the points at " { $snippet "xmin" } " and " { $snippet "xmax" } " are in the data set. All of the above is done by " { $link clip-data } "."
$nl
"At this point either the data set is empty, or there is at least some intersection between the data and the viewport. The task of the next step is to produce a sequence of lines that can be drawn on the viewport. The " { $link drawable-chunks } " word cuts away all the data outside the viewport, adding the intersection points where necessary. It does so by first grouping the data points into subsequences (chunks), in which all points are either above, below or within the " { $snippet "[ymin,ymax]" } " limits (" { $link monotonic-split-slice } " using " { $link between<=> } ")."
$nl
"Those chunks are then examined pairwise by " { $link (drawable-chunks) } " and edge points are calculated and added where necessary by " { $link (make-pair) } ". For example, if a chunk is within the viewport, and the next one is above the viewport, then a point should be added to the end of the first chunk, connecting its last point to the point of the viewport boundary intersection (" { $link fix-left-chunk } ", and " { $link fix-right-chunk } " for the opposite case). If a chunk is below the viewport, and the next one is above the viewport (or vice versa), then a new 2-point chunk should be created so that the intersecting line would be drawn within the viewport boundaries (" { $link 2-point-chunk } ")."
$nl
"The data are now filtered down to contain only the subset that is relevant to the currently chosen visible range, and is split into chunks that can each be drawn in a single contuguous stroke."
$nl
"Since the display uses inverted coordinate system, with " { $snippet "y" } " = 0 at the top of the screen, and growing downwards, we need to flip the data along the horizontal center line (" { $link flip-y-axis } ")."
$nl
"Finally, the data needs to be scaled so that its coordinates are mapped to the screen coordinates (" { $link scale-chunks } "). This last step could probably be combined with flipping the " { $snippet "y" } " coordinate for extra performance."
$nl
"The resulting chunks are displayed with a call to " { $link draw-line } " each."
;

HELP: clip-data
{ $values
    { "bounds" "{ { xmin xmax } { ymin ymax } }" }
    { "data" { $link sequence } " of { x y } pairs sorted by non-descending x" }
    { "data'" "possibly empty subsequence of " { $snippet "data" } }
}
{ $description "Filter the " { $snippet "data" } " by first removing all points outside the " { $snippet "[xmin,xmax]" } " range, and then making sure that the remaining " { $snippet "y" } " values are not entirely above or below the " { $snippet "[ymin,ymax]" } " range." } ;

HELP: draw-line
{ $values
    { "seq" { $link sequence } " of { x y } pairs, in pixels" }
}
{ $description "Draw a sequence of straight line segments connecting all consecutive points with a single OpenGL call. Intended to be called by a " { $link draw-gadget* } " implementation." } ;

HELP: line
{ $class-description "This is a " { $link gadget } " which, when added as a child to the " { $link chart } ", will display its data as straight line segments. The implementation is oriented towards speed to allow large data sets to be displayed as quickly as possible."
$nl
"Slots:"
{ $slots
    { "data" { "a " { $link sequence } " of { x y } pairs sorted by non-descending x;" } }
    { "color" { "a " { $link color } " to draw the line with." } }
} } ;

HELP: y-at
{ $description "Given two points on a straight line and an " { $snippet "x" } " coordinate, calculate the " { $snippet "y" } " coordinate at " { $snippet "x" } " on that line." }
{ $values
    { "x" object }
    { "point1" object }
    { "point2" object }
    { "y" object }
}
{ $examples
    { $example
        "USING: ui.gadgets.charts.lines.private prettyprint ;"
        "0 { 1 1 } { 5 5 } y-at ."
        "0"
    }
    { $example
        "USING: ui.gadgets.charts.lines.private prettyprint ;"
        "3 { 0 5 } { 5 5 } y-at ."
        "5"
    }
    { $example
        "USING: ui.gadgets.charts.lines.private prettyprint ;"
        "12 { 12 50 } { 15 15 } y-at ."
        "50"
    }
} ;

HELP: calc-x
{ $description "Given the " { $snippet "slope" } " of a line and a random " { $snippet "point" } " belonging to that line, calculate the " { $snippet "x" } " coordinate corresponding to the given " { $snippet "y" } "." }
{ $values
    { "slope" object }
    { "y" object }
    { "point" object }
    { "x" object }
}
{ $examples
    { $example
        "USING: ui.gadgets.charts.lines.private prettyprint ;"
        "1 5 { 1 1 } calc-x ."
        "5"
    }
    { $example
        "USING: ui.gadgets.charts.lines.private prettyprint ;"
        "0.5 10 { 0 0 } calc-x ."
        "20.0"
    }
} ;

HELP: calc-y
{ $description "Given the " { $snippet "slope" } " of a line and a random " { $snippet "point" } " belonging to that line, calculate the " { $snippet "y" } " coordinate corresponding to the given " { $snippet "x" } "." }
{ $values
    { "slope" object }
    { "x" object }
    { "point" object }
    { "y" object }
}
{ $examples
    { $example
        "USING: ui.gadgets.charts.lines.private prettyprint ;"
        "1 5 { 1 1 } calc-y ."
        "5"
    }
    { $example
        "USING: ui.gadgets.charts.lines.private prettyprint ;"
        "0.5 20 { 0 0 } calc-y ."
        "10.0"
    }
} ;

HELP: calc-line-slope
{ $description "Given the two points belonging to a straight line, calculate the " { $snippet "slope" } " of the line, assuming the line equation is " { $snippet "y(x) = slope * x + b" } "."
{ $values
    { "point1" object }
    { "point2" object }
    { "slope" object }
}
$nl
"The formula for the calculation is " { $snippet "slope = (y1-y2) / (x1-x2)" } ", therefore it'll throw a division by zero error if both points have the same " { $snippet "x" } " coordinate." }
{ $examples
    { $example
        "USING: ui.gadgets.charts.lines.private prettyprint ;"
        "{ 1 1 } { 10 10 } calc-line-slope ."
        "1"
    }
    { $example
        "USING: ui.gadgets.charts.lines.private prettyprint ;"
        "{ 0 0 } { 10 20 } calc-line-slope ."
        "2"
    }
} ;

{ calc-line-slope y-at calc-x calc-y } related-words
