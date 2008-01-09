USING: ui.gadgets help.markup help.syntax ui.gadgets.worlds
kernel ;
IN: ui.gadgets.menus

HELP: <commands-menu>
{ $values { "hook" "a quotation with stack effect " { $snippet "( button -- )" } } { "target" object } { "commands" "a sequence of commands" } { "gadget" "a new " { $link gadget } } }
{ $description "Creates a popup menu of commands which are to be invoked on " { $snippet "target" } ". The " { $snippet "hook" } " quotation is run before a command is invoked." } ;

HELP: show-menu
{ $values { "gadget" gadget } { "owner" gadget } }
{ $description "Displays a popup menu in the " { $link world } " containing " { $snippet "owner" } " at the current mouse location." } ;
