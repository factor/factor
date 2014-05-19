USING: ui.gadgets help.markup help.syntax ui.gadgets.worlds
kernel ;
IN: ui.gadgets.menus

HELP: <commands-menu>
{ $values { "target" object } { "hook" { $quotation ( button -- ) } } { "commands" "a sequence of commands" } { "menu" "a new " { $link gadget } } }
{ $description "Creates a popup menu of commands which are to be invoked on " { $snippet "target" } ". The " { $snippet "hook" } " quotation is run before a command is invoked." } ;

HELP: show-menu
{ $values { "owner" gadget } { "menu" gadget } }
{ $description "Displays a popup menu in the " { $link world } " containing " { $snippet "owner" } " at the current mouse location. The popup menu can be any gadget." } ;

HELP: show-commands-menu
{ $values { "target" gadget } { "commands" "a sequence of commands" } }
{ $description "Displays a popup menu with the given commands. The commands act on the target gadget. This is just a convenience word that combines " { $link <commands-menu> } " with " { $link show-menu } "." }
{ $notes "Useful for right-click context menus." } ;

ARTICLE: "ui.gadgets.menus" "Popup menus"
"The " { $vocab-link "ui.gadgets.menus" } " vocabulary displays popup menus in " { $link "ui.gadgets.glass" } "."
{ $subsections
    <commands-menu>
    show-menu
    show-commands-menu
} ;

ABOUT: "ui.gadgets.menus"
