USING: continuations help.markup help.syntax ;
IN: ui.tools.debugger

HELP: <debugger>
{ $values { "error" "an error" } { "continuation" continuation } { "restarts" "a sequence of " { $link restart } " instances" } { "restart-hook" { $quotation ( debugger -- ) } } { "debugger" "a new " { $link debugger } } }
{ $description
    "Creates a gadget displaying a description of the error, along with buttons to print the contents of the stacks in the listener, and a list of restarts."
} ;

{ <debugger> debugger-window } related-words

HELP: debugger-window
{ $values { "error" "an error" } { "continuation" continuation } }
{ $description "Opens a window with a description of the error." } ;
