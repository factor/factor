USING: help.markup help.syntax ui.commands ui.operations
ui.gadgets.editors ui.gadgets.panes listener io words
ui.tools.listener.completion ui.tools.common help.tips
tools.vocabs vocabs ;
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
{ $operations T{ vocab-link f "kernel" } }
{ $command-map interactor "quotation" }
{ $heading "Editing commands" }
"The text editing commands are standard; see " { $link "gadgets-editors-commands" } "."
{ $heading "Implementation" }
"Listeners are instances of " { $link listener-gadget } ". The listener consists of an output area (instance of " { $link pane } ") and an input area (instance of " { $link interactor } "). Clickable presentations can also be printed to the listener; see " { $link "ui-presentations" } "." ;

TIP: "You can read documentation by pressing F1." ;

TIP: "The listener tool remembers previous lines of input. Press " { $command interactor "completion" recall-previous } " and " { $command interactor "completion" recall-next } " to cycle through them." ;

TIP: "When you mouse over certain objects, a block border will appear. Left-clicking on such an object will perform the default operation. Right-clicking will show a menu with all operations." ;

TIP: "The status bar displays stack effects of recognized words as they are being typed in." ;

TIP: "Press " { $command interactor "completion" code-completion-popup } " to complete word, vocabulary and Unicode character names. The latter two features become available if the cursor is after a " { $link POSTPONE: USE: } ", " { $link POSTPONE: USING: } " or " { $link POSTPONE: CHAR: } "." ;

TIP: "If a word's vocabulary is loaded, but not in the search path, you can use restarts to add the vocabulary to the search path. Auto-use mode (" { $command listener-gadget "toolbar" com-auto-use } ") invokes restarts automatically if there is only one restart." ;

TIP: "Scroll the listener from the keyboard by pressing " { $command listener-gadget "scrolling" com-page-up } " and " { $command listener-gadget "scrolling" com-page-down } "." ;

TIP: "Press " { $command tool "common" refresh-all } " or run " { $link refresh-all } " to reload changed source files from disk. " ;

ABOUT: "ui-listener"