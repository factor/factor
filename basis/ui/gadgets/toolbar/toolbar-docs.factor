USING: help.markup help.syntax ui.gadgets ui.gadgets.buttons
ui.gadgets.labels ui.pens kernel models classes ;
IN: ui.gadgets.toolbar

HELP: <toolbar>
{ $values { "target" object } { "toolbar" gadget } }
{ $description "Creates a row of " { $link <command-button> } " gadgets invoking commands on " { $snippet "target" } ". The commands are taken from the " { $snippet "\"toolbar\"" } " command group of each class in " { $snippet "classes" } "." } ;

ABOUT: "ui.gadgets.toolbar"
