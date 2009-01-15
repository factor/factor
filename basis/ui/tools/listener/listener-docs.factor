USING: help.markup help.syntax ui.commands
ui.gadgets.editors ui.gadgets.panes listener io ;
IN: ui.tools.listener

HELP: interactor
{ $class-description "An interactor is an " { $link editor } " intended to be used as the input component of a " { $link "ui-listener" } "."
$nl
"Interactors are created by calling " { $link <interactor> } "."
$nl
"Interactors implement the " { $link stream-readln } ", " { $link stream-read } " and " { $link read-quot } " generic words." } ;

ARTICLE: "ui-listener-completion" "Word and vocabulary completion"
"The listener is great"
;

ARTICLE: "ui-listener" "UI listener"
"The graphical listener is based around the terminal listener (" { $link "listener" } ") and adds the following features:"
{ $list
    "Input history"
    { "Completion (see " { $link "ui-listener-completion" } ")" }
    { "Clickable presentations (see " { $link "ui-presentations" } ")" }
}
{ $command-map listener-gadget "toolbar" }
{ $command-map listener-gadget "scrolling" }
{ $command-map listener-gadget "multi-touch" }
{ $command-map interactor "interactor" }
{ $command-map source-editor "word" }
{ $command-map interactor "quotation" }
{ $heading "Editing commands" }
"The text editing commands are standard; see " { $link "gadgets-editors" } "."
{ $heading "Implementation" }
"Listeners are instances of " { $link listener-gadget } ". The listener consists of an output area (instance of " { $link pane } ") and an input area (instance of " { $link interactor } ")." ;

ABOUT: "ui-listener"