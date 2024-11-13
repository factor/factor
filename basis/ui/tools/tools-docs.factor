USING: editors help.markup help.syntax summary inspector io io.styles
listener parser prettyprint tools.walker ui.commands
ui.gadgets.panes ui.gadgets.presentations ui.gestures
ui.operations ui.tools.operations ui.tools.common
vocabs see help.tips ;
IN: ui.tools

ARTICLE: "starting-ui-tools" "Starting the UI tools"
"The UI tools start automatically where possible:"
{ $list
    { "On Windows, the tools start when the Factor executable is run." }
    { "On X11, the tools start if the " { $snippet "DISPLAY" } " environment variable is set." }
    { "On macOS, the tools start if the " { $snippet "Factor.app" } " application bundle is run." }
}
"In all cases, passing the " { $snippet "-run=listener" } " command line switch starts the terminal listener instead. The UI can be started from the terminal by issuing the following command:"
{ $code "USE: threads" "[ \"ui.tools\" run ] in-thread" } ;

ARTICLE: "ui-shortcuts" "UI tool keyboard shortcuts"
"Every UI tool has its own set of keyboard shortcuts. Mouse-over a toolbar button to see its shortcut, if any, in the status bar, or press " { $snippet "F1" } " to see a list of all shortcuts supported by the tool."
$nl
"Some common shortcuts are supported by all tools:"
{ $command-map tool "tool-switching" }
{ $command-map tool "common" }
{ $command-map tool "fonts" } ;

ARTICLE: "ui-presentations" "Presentations in the UI"
"A " { $emphasis "presentation" } " is a graphical view of an object which is directly linked to the object in some way. The help article links you see in the documentation browser are presentations; and if you " { $link see } " a word in the UI listener, all words in the definition will themselves be presentations."
$nl
"When you move the mouse over a presentation, it is highlighted with a rectangular border and a short summary of the object being presented is shown in the status bar (the summary is produced using the " { $link summary } " word)."
$nl
"Clicking a presentation with the left mouse button invokes a default operation, which usually views the object in some way. For example, clicking a presentation of a word jumps to the word definition in the " { $link "ui-browser" } "."
$nl
"Clicking the right mouse button on a presentation displays a popup menu listing available operations."
$nl
"For more about presentation gadgets, see " { $link "ui.gadgets.presentations" } "." ;

ARTICLE: "ui-cocoa" "Functionality specific to macOS"
"On macOS, the Factor UI offers additional features which integrate with this operating system."
$nl
"First, a standard macOS-style menu bar is provided, which offers the bare minimum of what you would expect from a macOS application."
$nl
"Dropping a source file onto the Factor icon in the dock runs the source file in the listener."
$nl
"If you install " { $strong "Factor.app" } " in your " { $strong "Applications" } " folder, then other applications will be able to call Factor via the System Services feature. For example, you can select some text in " { $strong "TextEdit.app" } ", then invoke the " { $strong "TextEdit -> Services -> Factor -> Evaluate Selection" } " menu item, which will replace the selected text with the result of evaluating it in Factor."
;

ARTICLE: "ui-windows" "Functionality specific to Windows"
"Files can be dropped from other applications onto the listener window to push their names onto the stack:"
{ $subsections "filedrop-gestures" } ;

ARTICLE: "ui-tools" "UI developer tools"
"The " { $vocab-link "ui.tools" } " vocabulary hierarchy implements a collection of simple developer tools."
{ $subsections "starting-ui-tools" }
"To take full advantage of the UI tools, you should be using a supported text editor. See " { $link "editor" } "."
$nl
"Common functionality:"
{ $subsections
    "ui-shortcuts"
    "ui-presentations"
    "definitions.icons"
}
"Tools:"
{ $subsections
    "ui-listener"
    "ui-browser"
    "ui-inspector"
    "ui.tools.error-list"
    "ui-walker"
    "ui.tools.deploy"
}
"Platform-specific features:"
{ $subsections
    "ui-cocoa"
    "ui-windows"
} ;

TIP: "All UI developer tools support a common set of " { $link "ui-shortcuts" } ". Each individual tool has its own shortcuts as well; the F1 key is context-sensitive." ;

ABOUT: "ui-tools"
