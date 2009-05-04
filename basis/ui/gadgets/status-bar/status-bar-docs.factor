USING: help.markup help.syntax models strings
ui.gadgets ui.gadgets.worlds ui ;
IN: ui.gadgets.status-bar

HELP: show-status
{ $values { "string/f" string } { "gadget" gadget } }
{ $description "Displays a status message in the gadget's world." }
{ $notes "The status message will only be visible if the window was opened with " { $link open-status-window } ", and not " { $link open-window } "." } ;

HELP: hide-status
{ $values { "gadget" gadget } }
{ $description "Hides the status message in the gadget's world." }
{ $notes "The gadget passed in must be the gadget passed to " { $link show-status } ", otherwise the word does nothing. This ensures that one gadget does not hide another gadget's status message." } ;

HELP: <status-bar>
{ $values { "model" model } { "gadget" "a new " { $link gadget } } }
{ $description "Creates a new " { $link gadget } " displaying the model value, which must be a string or " { $link f } "." }
{ $notes "If the " { $snippet "model" } " is " { $snippet "status" } ", this gadget will display mouse over help for " { $link "ui.gadgets.presentations" } "." } ;

HELP: open-status-window
{ $values { "gadget" gadget } { "title/attributes" { "a " { $link string } " or a " { $link world-attributes } " tuple" } } }
{ $description "Like " { $link open-window } ", with the additional feature that the new window iwll have a status bar displaying the value stored in the world's " { $slot "status" } " slot." }
{ $see-also show-status hide-status } ;

ARTICLE: "ui.gadgets.status-bar" "Status bars and mouse-over help"
"The " { $vocab-link "ui.gadgets.status-bar" } " vocabulary implements a word to display windows with a status bar."
{ $subsection open-status-window }
"Gadgets can use a pair of words to show and hide status bar messages. These words will work in any gadget, but will have no effect unless the gadget is displayed inside a window with a status bar."
{ $subsection show-status }
{ $subsection hide-status }
{ $link "ui.gadgets.presentations" } " use the status bar to display object summary." ;

ABOUT: "ui.gadgets.status-bar"
