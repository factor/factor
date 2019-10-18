USING: help.markup help.syntax ui.gadgets models ;
IN: ui.gadgets.viewports

HELP: viewport
{ $class-description "A viewport is a control which positions a child gadget translated by the " { $link control-value } " vector. Viewports can be created directly by calling " { $link <viewport> } "." } ;

HELP: <viewport>
{ $values { "content" gadget } { "model" model } { "viewport" "a new " { $link viewport } } }
{ $description "Creates a new " { $link viewport } " containing " { $snippet "content" } "." } ;
