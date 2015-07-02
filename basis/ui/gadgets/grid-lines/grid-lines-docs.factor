USING: ui.gadgets help.markup help.syntax ui.gadgets.grids
ui.pens colors ;
IN: ui.gadgets.grid-lines

HELP: grid-lines
{ $class-description "A class implementing the " { $link draw-boundary } " generic word to draw lines between the cells of a " { $link grid } ". The color of the lines is an instance of " { $link color } ", stored in the " { $snippet "color" } " slot." }
{ $notes "See " { $link "colors" } "." } ;

HELP: <grid-lines>
{ $values { "color" color } { "grid-lines" grid-lines } }
{ $description "Creates a new " { $link grid-lines } "." } ;

ARTICLE: "ui.gadgets.grid-lines" "Grid lines"
{ $subsections
    grid-lines
    <grid-lines>
} ;

ABOUT: "ui.gadgets.grid-lines"
