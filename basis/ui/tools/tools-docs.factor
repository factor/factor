USING: editors help.markup help.syntax summary inspector io
io.styles listener parser prettyprint tools.profiler
tools.walker ui.commands ui.gadgets.editors ui.gadgets.panes
ui.gadgets.presentations ui.gadgets.slots ui.operations
ui.tools.browser ui.tools.interactor ui.tools.inspector
ui.tools.listener ui.tools.operations ui.tools.profiler
ui.tools.walker ui.tools.workspace vocabs ;
IN: ui.tools

ARTICLE: "ui-presentations" "Presentations in the UI"
"A " { $emphasis "presentation" } " is a graphical view of an object which is directly linked to the object in some way. The help article links you see in the documentation browser are presentations; and if you " { $link see } " a word in the UI listener, all words in the definition will themselves be presentations."
$nl
"When you move the mouse over a presentation, it is highlighted with a rectangular border and a short summary of the object being presented is shown in the status bar (the summary is produced using the " { $link summary } " word)."
$nl
"Clicking a presentation with the left mouse button invokes a default operation, which usually views the object in some way. For example, clicking a presentation of a word jumps to the word definition in the " { $link "ui-browser" } "."
$nl
"Clicking and holding the right mouse button on a presentation displays a popup menu listing available operations."
$nl
"Presentation gadgets can be constructed directly using the " { $link <presentation> } " word, and they can also be written to " { $link pane } " gadgets using the " { $link write-object } " word." ;

ARTICLE: "ui-listener" "UI listener"
"The graphical listener is based around the terminal listener (" { $link "listener" } ") and adds the following features:"
{ $list
    "Input history"
    { "Completion (see " { $link "ui-completion" } ")" }
    { "Clickable presentations (see " { $link "ui-presentations" } ")" }
}
{ $command-map listener-gadget "toolbar" }
{ $command-map interactor "interactor" }
{ $command-map source-editor "word" }
{ $command-map interactor "quotation" }
{ $heading "Editing commands" }
"The text editing commands are standard; see " { $link "gadgets-editors" } "."
{ $heading "Implementation" }
"Listeners are instances of " { $link listener-gadget } ". The listener consists of an output area (instance of " { $link pane } ") and an input area (instance of " { $link interactor } ")." ;

ARTICLE: "ui-inspector" "UI inspector"
"The graphical inspector builds on the terminal inspector (see " { $link "inspector" } ") and provides in-place editing of slot values."
$nl
"To display an object in the UI inspector, use the " { $link inspect } " word from the UI listener, or right-click a presentation and choose " { $strong "Inspect" } " from the menu that appears."
$nl
"When the UI inspector is running, all of the terminal inspector words are available, such as " { $link &at } " and " { $link &put } ". Changing slot values using terminal inspector words automatically updates the UI inspector display."
$nl
"Slots can also be edited graphically. Clicking the ellipsis to the left of the slot's textual representation displays a slot editor gadget. A text representation of the object can be edited in the slot editor. The parser is used to turn the text representation back into an object. Keep in mind that some structure is lost in the conversion; see " { $link "prettyprint-limitations" } "."
$nl
"The slot editor's text editing commands are standard; see " { $link "gadgets-editors" } "."
$nl
"The slot editor has a toolbar containing various commands."
{ $command-map slot-editor "toolbar" }
{ $command-map inspector-gadget "multi-touch" }
"The following commands are also available."
{ $command-map source-editor "word" } ;

ARTICLE: "ui-browser" "UI browser"
"The browser is used to display Factor code, documentation, and vocabularies."
{ $command-map browser-gadget "toolbar" }
{ $command-map browser-gadget "multi-touch" }
"Browsers are instances of " { $link browser-gadget } "." ;

ARTICLE: "ui-profiler" "UI profiler" 
"The graphical profiler is based on the terminal profiler (see " { $link "profiling" } ") and adds more convenient browsing of profiler results."
$nl
"To use the profiler, enter a piece of code in the listener input area and press " { $operation com-profile } "."
$nl
"Vocabulary and word presentations in the profiler pane can be clicked on to show profiler results pertaining to the object in question. Clicking a vocabulary in the profiler yields the same output as the " { $link vocab-profile. } " word, and clicking a word yields the same output as the " { $link usage-profile. } " word. Consult " { $link "profiling" } " for details."
{ $command-map profiler-gadget "toolbar" } ;

ARTICLE: "ui-cocoa" "Functionality specific to Mac OS X"
"On Mac OS X, the Factor UI offers additional features which integrate with this operating system."
$nl
"First, a standard Mac-style menu bar is provided, which offers the bare minimum of what you would expect from a Mac OS X application."
$nl
"Dropping a source file onto the Factor icon in the dock runs the source file in the listener."
$nl
"If you install " { $strong "Factor.app" } " in your " { $strong "Applications" } " folder, then other applications will be able to call Factor via the System Services feature. For example, you can select some text in " { $strong "TextEdit.app" } ", then invoke the " { $strong "TextEdit->Services->Factor->Evaluate Selection" } " menu item, which will replace the selected text with the result of evaluating it in Factor."

;

ARTICLE: "ui-completion-words" "Word completion popup"
"Clicking a word in the word completion popup displays the word definition in the " { $link "ui-browser" } ". Pressing " { $snippet "RET" } " with a word selected inserts the word name in the listener, along with a " { $link POSTPONE: USE: } " declaration (if necessary)."
{ $operations \ $operations } ;

ARTICLE: "ui-completion-vocabs" "Vocabulary completion popup"
"Clicking a vocabulary in the vocabulary completion popup displays a list of words in the vocabulary in another " { $link "ui-completion-words" } ". Pressing " { $snippet "RET" } " adds the vocabulary to the current search path, just as if you invoked " { $link POSTPONE: USE: } "."
{ $operations "kernel" vocab } ;

ARTICLE: "ui-completion-sources" "Source file completion popup"
"The source file completion popup lists all source files which have been previously loaded by " { $link run-file } ". Clicking a source file or pressing " { $snippet "RET" } " opens the source file in your editor with " { $link edit } "."
{ $operations P" " } ;

ARTICLE: "ui-completion" "UI completion popups"
"Completion popups allow fast access to aspects of the environment. Completion popups can be invoked by clicking the row of buttons along the bottom of the workspace, or via keyboard commands:"
{ $command-map workspace "toolbar" }
"A completion popup instantly updates the list of completions as keys are typed. The list of completions can be navigated from the keyboard with the " { $snippet "UP" } " and " { $snippet "DOWN" } " arrow keys. Every completion has a " { $emphasis "primary action" } " and " { $emphasis "secondary action" } ". The primary action is invoked when clicking a completion, and the secondary action is invoked on the currently-selected completion when pressing " { $snippet "RET" } "."
$nl
"The primary and secondary actions, along with additional keyboard shortcuts, are documented for some completion popups in the below sections."
{ $subsection "ui-completion-words" }
{ $subsection "ui-completion-vocabs" }
{ $subsection "ui-completion-sources" } ;

ARTICLE: "ui-workspace-keys" "UI keyboard shortcuts"
"See " { $link "gesture-differences" } " to find out how your platform's modifier keys map to modifiers in the Factor UI."
{ $command-map workspace "tool-switching" }
{ $command-map workspace "scrolling" }
{ $command-map workspace "workflow" }
{ $command-map workspace "multi-touch" } ;

ARTICLE: "ui-tools" "UI developer tools"
"The Factor development environment can seem rather different from what you are used to, because it is very simple and powerful.."
$nl
"To take full advantage of the UI, you should be using a supported text editor. See " { $link "editor" } "."
{ $subsection "ui-workspace-keys" }
{ $subsection "ui-presentations" }
{ $subsection "ui-completion" }
{ $heading "Tools" }
"A single-window " { $emphasis "workspace" } " contains the most frequently-used tools:"
{ $subsection "ui-listener" }
{ $subsection "ui-browser" }
{ $subsection "ui-inspector" }
{ $subsection "ui-profiler" }
"Additional tools:"
{ $subsection "ui-walker" }
{ $subsection "ui.tools.deploy" }
"Platform-specific features:"
{ $subsection "ui-cocoa" } ;

ABOUT: "ui-tools"
