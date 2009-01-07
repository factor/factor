USING: help.markup help.syntax ui.commands ui.tools.interactor
ui.gadgets.editors ui.gadgets.panes ;
IN: ui.tools.listener

ARTICLE: "ui-listener" "UI listener"
"The graphical listener is based around the terminal listener (" { $link "listener" } ") and adds the following features:"
{ $list
    "Input history"
    { "Completion (see " { $link "ui-completion" } ")" }
    { "Clickable presentations (see " { $link "ui-presentations" } ")" }
}
{ $command-map listener-gadget "toolbar" }
{ $command-map listener-gadget "scrolling" }
{ $command-map interactor "interactor" }
{ $command-map source-editor "word" }
{ $command-map interactor "quotation" }
{ $heading "Editing commands" }
"The text editing commands are standard; see " { $link "gadgets-editors" } "."
{ $heading "Implementation" }
"Listeners are instances of " { $link listener-gadget } ". The listener consists of an output area (instance of " { $link pane } ") and an input area (instance of " { $link interactor } ")." ;

ABOUT: "ui-listener"