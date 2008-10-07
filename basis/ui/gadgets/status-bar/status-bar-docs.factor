USING: help.markup help.syntax models
ui.gadgets ui.gadgets.worlds ;
IN: ui.gadgets.status-bar

HELP: <status-bar>
{ $values { "model" model } { "gadget" "a new " { $link gadget } } }
{ $description "Creates a new " { $link gadget } " displaying the model value, which must be a string or " { $link f } "." }
{ $notes "If the " { $snippet "model" } " is " { $snippet "status" } ", this gadget will display mouse over help for " { $link "ui.gadgets.presentations" } "." } ;
