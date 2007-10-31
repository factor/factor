USING: ui.gadgets.controls help.markup
help.syntax strings ui.gadgets models ;
IN: ui.gadgets.labels

HELP: label
{ $class-description "A label displays a piece of text, either a single line string or an array of line strings. Labels are created by calling " { $link <label> } "." } ;

HELP: <label>
{ $values { "string" string } { "label" "a new " { $link label } } }
{ $description "Creates a new " { $link label } " gadget. The string is permitted to contain line breaks." } ;

HELP: label-string
{ $values { "label" label } { "string" string } }
{ $description "Outputs the string currently displayed by the label." } ;

HELP: set-label-string
{ $values { "label" label } { "string" string } }
{ $description "Sets the string currently displayed by the label. The string is permitted to contain line breaks. After calling this word, you must also call " { $link relayout } " on the label." } ;

HELP: <label-control>
{ $values { "model" model } { "gadget" "a new " { $link gadget } } }
{ $description "Creates a " { $link control } " which displays the value of " { $snippet "model" } ", which is required to be a string. The label control is automatically updated when the model value changes." } ;

{ label-string set-label-string } related-words
{ <label> <label-control> } related-words

ARTICLE: "ui.gadgets.labels" "Label gadgets"
"A label displays a piece of text, either a single line string or an array of line strings."
{ $subsection label }
{ $subsection <label> }
{ $subsection <label-control> }
{ $subsection label-string }
{ $subsection set-label-string }
"Label specifiers are used by buttons, checkboxes and radio buttons:"
{ $subsection >label } ;

ABOUT: "ui.gadgets.labels"

HELP: >label
{ $values { "obj" "a label specifier" } { "gadget" "a new " { $link gadget } } }
{ $description "Convert the object into a gadget suitable for use as the label of a button. If " { $snippet "obj" } " is already a gadget, does nothing. Otherwise creates a " { $link label } " gadget if it is a string and an empty gadget if " { $snippet "obj" } " is " { $link f } "." } ;
