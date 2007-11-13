USING: ui.gadgets.viewports help.markup
help.syntax ui.gadgets models ;

HELP: viewport
{ $class-description "A viewport is a " { $link control } " which positions a child gadget translated by the " { $link control-value } " vector. Viewports can be created directly by calling " { $link <viewport> } "." } ;

HELP: <viewport>
{ $values { "content" gadget } { "model" model } { "viewport" "a new " { $link viewport } } }
{ $description "Creates a new " { $link viewport } " containing " { $snippet "content" } "." } ;
