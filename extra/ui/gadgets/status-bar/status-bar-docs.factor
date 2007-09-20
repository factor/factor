USING: ui.gadgets.status-bar ui.gadgets.presentations
help.markup help.syntax models ui.gadgets ui.gadgets.worlds ;

HELP: <status-bar>
{ $values { "model" model } { "gadget" "a new " { $link gadget } } }
{ $description "Creates a new " { $link gadget } " displaying the model value, which must be a string or " { $link f } "." }
{ $notes "If the " { $snippet "model" } " is " { $link world-status } ", this gadget will display " { $link presentation } " mouse over help." } ;

{ <status-bar> show-mouse-help show-status show-summary hide-status } related-words
