USING: help.markup help.syntax ui.gadgets math ;
IN: ui.gadgets.borders

HELP: border
{ $class-description "A border gadget contains a single child and centers it, with a fixed-width border. Borders are created by calling " { $link <border> } "." } ;

HELP: <border>
{ $values { "child" gadget } { "gap" integer } { "border" "a new " { $link border } } }
{ $description "Creates a new border around the child with the specified horizontal and vertical gap." } ;

ARTICLE: "ui.gadgets.borders" "Border gadgets"
"Border gadgets add empty space around a child gadget."
{ $subsection border }
{ $subsection <border> } ;

ABOUT: "ui.gadgets.borders"
