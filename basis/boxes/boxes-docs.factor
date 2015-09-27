USING: help.markup help.syntax kernel ;
IN: boxes

HELP: box
{ $class-description "A data type holding a single value in the " { $snippet "value" } " slot. The " { $snippet "occupied" } " slot indicates if the value is set." } ;

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
{ $values { "box" box } { "value/f" "the value of the box or " { $link f } } { "?" boolean } }
{ $description "If the box is full, removes the value from the box and pushes " { $link t } ". If the box is empty pushes " { $snippet "f f" } "." } ;

ARTICLE: "boxes" "Boxes"
"A " { $emphasis "box" } " is a container which can either be empty or hold a single value."
{ $subsections box }
"Creating an empty box:"
{ $subsections <box> }
"Storing a value and removing a value from a box:"
{ $subsections
    >box
    box>
}
"Safely removing a value:"
{ $subsections ?box }
"Testing if a box is full can be done by reading the " { $snippet "occupied" } " slot." ;

ABOUT: "boxes"
