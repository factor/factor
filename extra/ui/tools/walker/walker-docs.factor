IN: ui.tools.walker
USING: help.markup help.syntax ui.commands ui.operations
tools.walker ;

ARTICLE: "ui-walker" "UI walker"
"The walker single-steps through quotations. To use the walker, enter a piece of code in the listener's input area and press " { $operation walk } "."
$nl
"The walker can travel backwards through time, and restore stacks. This does not undo side effects and therefore can only be used reliably on referentially transparent code."
{ $command-map walker-gadget "toolbar" }
"Walkers are instances of " { $link walker-gadget } "." ;
