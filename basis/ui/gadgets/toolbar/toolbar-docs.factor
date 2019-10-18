USING: help.markup help.syntax kernel ui.gadgets
ui.gadgets.buttons ;
IN: ui.gadgets.toolbar

HELP: <toolbar>
{ $values { "target" object } { "toolbar" gadget } }
{ $description "Creates a row of " { $link <command-button> } " gadgets invoking commands on " { $snippet "target" } ". The commands are taken from the " { $snippet "\"toolbar\"" } " command group of the " { $snippet "target" } "'s class." } ;
