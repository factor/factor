USING: help.markup help.syntax strings ui.gadgets models ;
IN: ui.gadgets.labels

HELP: label
{ $class-description "A label displays a piece of text, either a single line string or an array of line strings. Labels are created by calling " { $link <label> } "." } ;

HELP: <label>
{ $values { "string" string } { "label" "a new " { $link label } } }
{ $description "Creates a new " { $link label } " gadget. The string is permitted to contain line breaks." } ;

HELP: <label-control>
{ $values { "model" model } { "gadget" "a new " { $link gadget } } }
{ $description "Creates a control which displays the value of " { $snippet "model" } ", which is required to be a string. The label control is automatically updated when the model value changes." } ;

{ <label> <label-control> } related-words

ARTICLE: "ui.gadgets.labels" "Label gadgets"
"The " { $vocab-link "ui.gadgets.labels" } " vocabulary implements labels. A label displays a piece of text, which is either a single line string or an array of line strings."
{ $subsections
    label
    <label>
    <label-control>
}
"Labels have a virtual slot named " { $slot "string" } " which contains the displayed text. The " { $slot "text" } " slot should not be set directly."
$nl
"Label specifiers are used by buttons, checkboxes and radio buttons:"
{ $subsections >label } ;

ABOUT: "ui.gadgets.labels"

HELP: >label
{ $values { "obj" "a label specifier" } { "gadget" "a new " { $link gadget } } }
{ $description "Convert the object into a gadget suitable for use as the label of a button. If " { $snippet "obj" } " is already a gadget, does nothing. Otherwise creates a " { $link label } " gadget if it is a string and an empty gadget if " { $snippet "obj" } " is " { $link f } "." } ;
