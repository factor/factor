USING: ui.gadgets help.markup help.syntax ui.gadgets.menus
ui.gadgets.worlds ;

HELP: show-menu
{ $values { "gadget" gadget } { "owner" gadget } }
{ $description "Displays a popup menu in the " { $link world } " containing " { $snippet "owner" } " at the current mouse location." } ;
