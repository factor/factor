USING: ui.gadgets help.markup help.syntax arrays ;
IN: ui.gadgets.grids

ARTICLE: "ui-grid-layout" "Grid layouts"
"Grid gadgets layout their children in a rectangular grid. The grid is represented as a sequence of sequences of gadgets. Every child sequence is a row of gadgets. Every row must have an equal number of gadgets in it."
{ $subsections grid }
"Creating grids from a fixed set of gadgets:"
{ $subsections <grid> }
"Managing children:"
{ $subsections
    grid-add
    grid-remove
    grid-child
}
"Grid lines:"
{ $subsections "ui.gadgets.grid-lines" } ;

HELP: grid
{ $class-description "A grid gadget lays out its children so that all gadgets in a column have equal width and all gadgets in a row have equal height."
$nl
"The " { $snippet "gap" } " slot stores a pair of integers, the horizontal and vertical gap between children, respectively."
$nl
"The " { $snippet "fill?" } " slot stores a boolean, indicating if grid cells should assume their preferred size, or if they should fill the dimensions of the cell. The default is " { $link t } "."
$nl
"Grids are created by calling " { $link <grid> } " and children are managed with " { $link grid-add } " and " { $link grid-remove } "."
$nl
"The " { $link add-gadget } ", " { $link unparent } " and " { $link clear-gadget } " words should not be used to manage child gadgets of grids." } ;

HELP: <grid>
{ $values { "children" "a sequence of sequences of gadgets, column-major" } { "grid" "a new " { $link grid } } }
{ $description "Creates a new " { $link grid } " gadget with the given children." } ;

HELP: grid-child
{ $values { "grid" grid } { "pair" "a pair with shape " { $snippet "{ col row }" } } { "gadget" gadget } }
{ $description "Outputs the child gadget at the specified location." }
{ $errors "Throws an error if the indices are out of bounds." } ;

HELP: grid-add
{ $values { "grid" grid } { "child" gadget } { "pair" "a pair with shape " { $snippet "{ col row }" } } }
{ $description "Adds a child gadget at the specified location." }
{ $errors "Throws an error if the indices are out of bounds." }
{ $side-effects "grid" } ;

HELP: grid-remove
{ $values { "grid" grid } { "pair" "a pair with shape " { $snippet "{ col row }" } } }
{ $description "Removes a child gadget from the specified location." }
{ $errors "Throws an error if the indices are out of bounds." }
{ $side-effects "grid" } ;

ABOUT: "ui-grid-layout"
