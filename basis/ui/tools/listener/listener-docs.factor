USING: help.markup help.syntax help.tips io kernel listener
sequences system ui.commands ui.gadgets.editors ui.gadgets.panes
ui.operations ui.tools.common ui.tools.listener.completion
vocabs vocabs.refresh words ;
IN: ui.tools.listener

HELP: <listener-gadget>
{ $values { "listener" listener-gadget } }
{ $description "Creates a new listener gadget." } ;

HELP: interactor
{ $class-description "An interactor is an " { $link editor } " intended to be used as the input component of a " { $link "ui-listener" } ". It has the following slots:"
{ $slots
  {
      "waiting"
      { "If waiting is " { $link t } ", the interactor is waiting for user input, and invoking " { $link evaluate-input } " resumes the thread." }
  }
}
"Interactors are created by calling " { $link <interactor> } "."
$nl
"Interactors implement the " { $link stream-readln } ", " { $link stream-read } " and " { $link stream-read-quot } " generic words." } ;

HELP: interactor-busy?
{ $values { "interactor" interactor } { "?" boolean } }
{ $description "We're busy if there's no thread to resume." } ;

HELP: interactor-read
{ $values { "interactor" interactor } { "lines" sequence } }
{ $description "Implements the " { $link stream-readln } " generic for the interactor." } ;

HELP: wait-for-listener
{ $values { "listener" listener-gadget } }
{ $description "Wait up to five seconds for the listener to start." } ;

ARTICLE: "ui-listener" "UI listener"
"The graphical listener adds input history and word and vocabulary completion. A summary with any outstanding error conditions is displayed before every prompt (see " { $link "ui.tools.error-list" } " for details)."
$nl
"If the file " { $snippet "~/.factor-history" } " exists, input history is made persistent by appending history once the graphical listener closes and reading it back in upon (re)starting."
$nl
"See " { $link "listener" } " for general information on the listener."
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
$nl
{ $heading "Implementation" }
"Listeners are instances of " { $link listener-gadget } ". The listener consists of an output area (instance of " { $link pane } ") and an input area (instance of " { $link interactor } "). Clickable presentations can also be printed to the listener; see " { $link "ui-presentations" } "." ;

ARTICLE: "ui-listener-style" "UI listener styling"
"The graphical listener can be styled in a few ways:"
$nl
"1. Using the " { $vocab-link "ui.theme" } " vocabulary to control the theme colors."
$nl
"2. Setting the " { $link interactor-font } " to control the font used for rendering, as well as the " { $link listener-word-style } " which styles triggered commands and " { $link listener-input-style } " which styles the previous input lines."
$nl
"3. Using " { $link set-listener-font } " to change the font of the open listener (applied to subsequent output lines)."
$nl
"Typically these settings all affect new listener sessions, or output. If you want them to be saved, you can add them to your " { $snippet "~/.factor-rc" } " configuration file."
;

TIP: "You can read documentation by pressing " { $snippet "F1" } "." ;

TIP: "The listener tool remembers previous lines of input. Press " { $command interactor "completion" recall-previous } " and " { $command interactor "completion" recall-next } " to cycle through them." ;

TIP: "When you mouse over certain objects, a black border will appear. Left-clicking on such an object will perform the default operation. Right-clicking will show a menu with all operations." ;

TIP: "The status bar displays stack effects of recognized words as they are being typed in." ;

TIP: "Press " { $command interactor "completion" code-completion-popup } " to complete word, vocabulary and Unicode character names. The latter two features become available if the cursor is after a " { $link POSTPONE: USE: } ", " { $link POSTPONE: USING: } " or " { $link POSTPONE: CHAR: } "." ;

TIP: "If a word's vocabulary is loaded, but not in the search path, you can use restarts to add the vocabulary to the search path. Auto-use mode (" { $command listener-gadget "toolbar" com-auto-use } ") invokes restarts automatically if there is only one restart." ;

TIP: "Scroll the listener from the keyboard by pressing " { $command listener-gadget "scrolling" com-page-up } " and " { $command listener-gadget "scrolling" com-page-down } "." ;

TIP: "Press " { $command tool "common" refresh-all } " or run " { $link refresh-all } " to reload changed source files from disk." ;

TIP: "On Windows: use " { $snippet "C+Break" } " to interrupt tight loops in your code started in the listener, such as" { $code "[ t ] [ ] while" } "Caution: this may crash the Factor runtime if the code uses cooperative multitasking or asynchronous I/O." ;

ABOUT: "ui-listener"
