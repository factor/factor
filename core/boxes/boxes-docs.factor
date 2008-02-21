USING: help.markup help.syntax kernel ;
IN: boxes

HELP: box
{ $class-description "A data type holding a single value in the " { $link box-value } " slot. The " { $link box-full? } " slot indicates if the value is set." } ;

HELP: <box>
{ $values { "box" box } }
{ $description "Creates a new empty box." } ;

HELP: >box
{ $values { "value" object } { "box" box } }
{ $description "Stores a value into a box." }
{ $errors "Throws an error if the box is full." } ;

HELP: box>
{ $values { "box" box } { "value" "the value of the box" } }
{ $description "Removes a value from a box." }
{ $errors "Throws an error if the box is empty." } ;

HELP: ?box
{ $values { "box" box } { "value" "the value of the box or " { $link f } } { "?" "a boolean" } }
{ $description "If the box is full, removes the value from the box and pushes " { $link t } ". If the box is empty pushes " { $snippet "f f" } "." } ;

ARTICLE: "boxes" "Boxes"
"A " { $emphasis "box" } " is a container which can either be empty or hold a single value."
{ $subsection box }
"Creating an empty box:"
{ $subsection <box> }
"Testing if a box is full:"
{ $subsection box-full? }
"Storing a value and removing a value from a box:"
{ $subsection >box }
{ $subsection box> }
"Safely removing a value:"
{ $subsection ?box } ;

ABOUT: "boxes"
