USING: help.markup help.syntax ui.commands ui.operations
ui.gadgets.editors ui.gadgets.panes listener io words ;
IN: ui.tools.listener

HELP: interactor
{ $class-description "An interactor is an " { $link editor } " intended to be used as the input component of a " { $link "ui-listener" } "."
$nl
"Interactors are created by calling " { $link <interactor> } "."
$nl
"Interactors implement the " { $link stream-readln } ", " { $link stream-read } " and " { $link read-quot } " generic words." } ;

ARTICLE: "ui-listener" "UI listener"
"The graphical listener is based around the terminal listener (" { $link "listener" } ") and adds an input history, and word and vocabulary completion."
{ $command-map listener-gadget "toolbar" }
{ $command-map interactor "completion" }
{ $command-map interactor "interactor" }
{ $command-map listener-gadget "scrolling" }
{ $command-map listener-gadget "multi-touch" }
{ $heading "Word commands" }
"These words operate on the word at the cursor."
{ $operations \ word }
{ $heading "Vocabulary commands" }
"These words operate on the vocabulary at the cursor."
{ $operations \ word }
{ $command-map interactor "quotation" }
{ $heading "Editing commands" }
"The text editing commands are standard; see " { $link "gadgets-editors-commands" } "."
{ $heading "Implementation" }
"Listeners are instances of " { $link listener-gadget } ". The listener consists of an output area (instance of " { $link pane } ") and an input area (instance of " { $link interactor } "). Clickable presentations can also be printed to the listener; see " { $link "ui-presentations" } "." ;

ABOUT: "ui-listener"