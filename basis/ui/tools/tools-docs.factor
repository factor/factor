USING: editors help.markup help.syntax summary inspector io
io.styles listener parser prettyprint tools.profiler
tools.walker ui.commands ui.gadgets.editors ui.gadgets.panes
ui.gadgets.presentations ui.gadgets.slots ui.operations
ui.tools.browser ui.tools.inspector
ui.tools.listener ui.tools.operations ui.tools.profiler
ui.tools.walker vocabs ;
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

ARTICLE: "ui-profiler" "UI profiler" 
"The graphical profiler is based on the terminal profiler (see " { $link "profiling" } ") and adds more convenient browsing of profiler results."
$nl
"To use the profiler, enter a piece of code in the listener input area and press " { $operation com-profile } "."
$nl
"Clicking on a vocabulary in the vocabulary list narrows down the word list to only include words from that vocabulary. The sorting options control the order of elements in the vocabulary and word lists. The search fields narrow down the list to only include words or vocabularies whose names contain a substring."
$nl
"Consult " { $link "profiling" } " for details about the profiler itself."
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

ARTICLE: "ui-tools" "UI developer tools"
"The Factor development environment can seem rather different from what you are used to, because it is very simple and powerful.."
$nl
"To take full advantage of the UI, you should be using a supported text editor. See " { $link "editor" } "."
{ $subsection "ui-presentations" }
{ $subsection "ui-listener" }
{ $subsection "ui-browser" }
{ $subsection "ui-inspector" }
{ $subsection "ui-profiler" }
{ $subsection "ui-walker" }
{ $subsection "ui.tools.deploy" }
"Platform-specific features:"
{ $subsection "ui-cocoa" } ;

ABOUT: "ui-tools"
