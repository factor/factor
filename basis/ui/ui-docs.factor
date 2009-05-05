USING: help.markup help.syntax strings quotations debugger
namespaces ui.backend ui.gadgets ui.gadgets.worlds
ui.gadgets.tracks ui.gadgets.packs ui.gadgets.grids
ui.gadgets.private math.rectangles colors ui.text fonts
kernel ui.private classes sequences ;
IN: ui

HELP: windows
{ $var-description "Global variable holding an association list mapping native window handles to " { $link world } " instances." } ;

{ windows open-window find-window world-attributes } related-words

HELP: open-window
{ $values { "gadget" gadget } { "title/attributes" { "a " { $link string } " or a " { $link world-attributes } " tuple" } } }
{ $description "Opens a native window containing " { $snippet "gadget" } " with the specified attributes. If a string is provided, it is used as the window title; otherwise, the window attributes are specified in a " { $link world-attributes } " tuple." } ;

HELP: world-attributes
{ $values { "world-class" class } { "title" string } { "status" gadget } { "gadgets" sequence } { "pixel-format-attributes" sequence } }
{ $class-description "Tuples of this class can be passed to " { $link open-window } " to control attributes of the window opened. The following attributes can be set:" }
{ $list
    { { $snippet "world-class" } " specifies the class of world to construct. " { $link world } " is the default." }
    { { $snippet "title" } " is the window title." }
    { { $snippet "status" } ", if specified, is a gadget that will be used as the window's status bar." }
    { { $snippet "gadgets" } " is a sequence of gadgets that will be placed inside the window." }
    { { $snippet "pixel-format-attributes" } " is a sequence of " { $link "ui.pixel-formats-attributes" } " that the window will request for its OpenGL pixel format." }
} ;

HELP: set-fullscreen?
{ $values { "?" "a boolean" } { "gadget" gadget } }
{ $description "Sets and unsets fullscreen mode for the gadget's world." } ;

HELP: fullscreen?
{ $values { "gadget" gadget } { "?" "a boolean" } }
{ $description "Queries the gadget's world to see if it is running in fullscreen mode." } ;

{ fullscreen? set-fullscreen? } related-words

HELP: find-window
{ $values { "quot" { $quotation "( world -- ? )" } } { "world" { $maybe world } } }
{ $description "Finds a native window such that the gadget passed to " { $link open-window } " satisfies the quotation, outputting " { $link f } " if no such gadget could be found. The front-most native window is checked first." } ;

HELP: register-window
{ $values { "world" world } { "handle" "a baackend-specific handle" } }
{ $description "Adds a window to the global " { $link windows } " variable." }
{ $notes "This word should only be called by the UI backend.  User code can open new windows with " { $link open-window } "." } ;

HELP: unregister-window
{ $values { "handle" "a baackend-specific handle" } }
{ $description "Removes a window from the global " { $link windows } " variable." }
{ $notes "This word should only be called only by the UI backend, and not user code." } ;

HELP: (with-ui)
{ $values { "quot" quotation } }
{ $contract "Starts the Factor UI." }
{ $notes "This is a low-level word; user code should call " { $link with-ui } " instead." } ;

HELP: start-ui
{ $values { "quot" quotation } }
{ $description "Called by the UI backend to initialize the platform-independent parts of UI. This word should be called after the backend is ready to start displaying new windows, and before the event loop starts." } ;

HELP: (open-window)
{ $values { "world" world } }
{ $description "Opens a native window containing the given world. This grafts the world by calling " { $link graft } ". Each world can only be displayed in one top-level window at a time." }
{ $notes "This word should not be called directly by user code. Instead, use " { $link open-window } "." } ;

HELP: raise-window
{ $values { "gadget" gadget } }
{ $description "Makes the native window containing the given gadget the front-most window." } ;

HELP: with-ui
{ $values { "quot" quotation } }
{ $description "Calls the quotation, starting the UI first if necessary." }
{ $notes "This combinator should be used in the " { $link POSTPONE: MAIN: } " word of a vocabulary, in order for the vocabulary to work when run from the UI listener (" { $snippet "\"my-app\" run" } " and the command line (" { $snippet "./factor -run=my-app" } ")." }
{ $examples "The " { $vocab-link "hello-ui" } " vocabulary implements a simple UI application which uses this combinator." } ;

HELP: beep
{ $description "Plays the system beep sound." } ;

ARTICLE: "ui-glossary" "UI glossary"
{ $table
    { "color" { "an instance of " { $link color } } }
    { "dimension" "a pair of integers denoting pixel size on screen" }
    { "font" { "an instance of " { $link font } } }
    { "gadget" { "a graphical element which responds to user input. Gadgets are tuples which (directly or indirectly) inherit from " { $link gadget } "." } }
    { "label specifier" { "a string, " { $link f } " or a gadget. See " { $link "ui.gadgets.buttons" } } }
    { "orientation specifier" { "one of " { $link horizontal } " or " { $link vertical } } }
    { "point" "a pair of integers denoting a pixel location on screen" }
} ;

ARTICLE: "building-ui" "Building user interfaces"
"A gadget is a graphical element which responds to user input. Gadgets are implemented as tuples which (directly or indirectly) inherit from " { $link gadget } ", which in turn inherits from " { $link rect } "."
{ $subsection gadget }
"Gadgets are arranged in a hierarchy, and all visible gadgets except for instances of " { $link world } " are contained in a parent gadget, stored in the " { $snippet "parent" } " slot."
{ $subsection "ui-geometry" }
{ $subsection "ui-layouts" }
{ $subsection "gadgets" }
{ $subsection "ui-windows" }
{ $subsection "ui.gadgets.status-bar" }
{ $see-also "models" } ;

ARTICLE: "gadgets" "Pre-made UI gadgets"
{ $subsection "ui.gadgets.labels" }
{ $subsection "ui.gadgets.borders" }
{ $subsection "ui.gadgets.labeled" }
{ $subsection "ui.gadgets.buttons" }
{ $subsection "ui.gadgets.sliders" }
{ $subsection "ui.gadgets.scrollers" }
{ $subsection "ui.gadgets.editors" }
{ $subsection "ui.gadgets.menus" }
{ $subsection "ui.gadgets.panes" }
{ $subsection "ui.gadgets.presentations" }
{ $subsection "ui.gadgets.tables" } ;

ARTICLE: "ui-geometry" "Gadget geometry"
"The " { $link gadget } " class inherits from the " { $link rect } " class, and thus all gadgets have a bounding box:"
{ $subsection "math.rectangles" }
"Word for converting from a child gadget's co-ordinate system to a parent's:"
{ $subsection relative-loc }
{ $subsection screen-loc }
"Hit testing:"
{ $subsection pick-up }
{ $subsection children-on } ;

ARTICLE: "ui-windows" "Top-level windows"
"Opening a top-level window:"
{ $subsection open-window }
"Finding top-level windows:"
{ $subsection find-window }
"Top-level windows are stored in a global variable:"
{ $subsection windows }
"When a gadget is displayed in a top-level window, or added to a parent which is already showing in a top-level window, a generic word is called allowing the gadget to perform initialization tasks:"
{ $subsection graft* }
"When the gadget is removed from a parent shown in a top-level window, or when the top-level window is closed, a corresponding generic word is called to clean up:"
{ $subsection ungraft* }
"The root of the gadget hierarchy in a window is a special gadget which is rarely operated on directly, but it is helpful to know it exists:"
{ $subsection world } ;

ARTICLE: "ui-backend" "Developing UI backends"
"None of the words documented in this section should be called directly by user code. They are only of interest when developing new UI backends."
{ $subsection "ui-backend-init" }
{ $subsection "ui-backend-windows" }
"UI backends may implement the " { $link "clipboard-protocol" } "." ;

ARTICLE: "ui-backend-init" "UI initialization and the event loop"
"An UI backend is required to define a method on the " { $link (with-ui) } " word. This word should contain backend initialization, together with some boilerplate:"
{ $code
    "IN: shells"
    ""
    ": ui"
    "    ... backend-specific initialization ..."
    "    start-ui"
    "    ... more backend-specific initialization ..."
    "    ... start event loop here ... ;"
}
"The above word must call the following:"
{ $subsection start-ui }
"The " { $link (with-ui) } " word must not return until the event loop has stopped and the UI has been shut down." ;

ARTICLE: "ui-backend-windows" "UI backend window management"
"The high-level " { $link open-window } " word eventually calls a low-level word which you must implement:"
{ $subsection open-world-window }
"This word should create a native window, store some kind of handle in the " { $snippet "handle" } " slot, then call two words:"
{ $subsection register-window }
"The following words must also be implemented:"
{ $subsection set-title }
{ $subsection raise-window }
"When a world needs to be redrawn, the UI will call a word automatically:"
{ $subsection draw-world }
"This word can also be called directly if the UI backend is notified by the window system that window contents have been invalidated. Before and after drawing, two words are called, which the UI backend must implement:"
{ $subsection select-gl-context }
{ $subsection flush-gl-context }
"If the user clicks the window's close box, you must call the following word:"
{ $subsection close-window } ;

ARTICLE: "ui-layouts" "Gadget hierarchy and layouts"
"A layout gadget is a gadget whose sole purpose is to contain other gadgets. Layout gadgets position and resize children according to a certain policy, taking the preferred size of the children into account. Gadget hierarchies are constructed by building up nested layouts."
{ $subsection "ui-layout-basics" }
"Common layout gadgets:"
{ $subsection "ui-pack-layout" }
{ $subsection "ui-track-layout" }
{ $subsection "ui-grid-layout" }
{ $subsection "ui-frame-layout" }
{ $subsection "ui-book-layout" }
"Advanced topics:"
{ $subsection "ui.gadgets.glass" }
{ $subsection "ui-null-layout" }
{ $subsection "ui-incremental-layout" }
{ $subsection "ui-layout-impl" }
{ $see-also "ui.gadgets.borders" } ;

ARTICLE: "ui-layout-basics" "Layout basics"
"Gadgets are arranged in a hierarchy, and all visible gadgets except for instances of " { $link world } " are contained in a parent gadget."
$nl
"Managing the gadget hierarchy:"
{ $subsection add-gadget }
{ $subsection unparent }
{ $subsection add-gadgets }
{ $subsection clear-gadget }
"The children of a gadget are available via the "
{ $snippet "children" } " slot. "
$nl
"Working with gadget children:"
{ $subsection gadget-child }
{ $subsection nth-gadget }
{ $subsection each-child }
{ $subsection child? }
"Working with gadget parents:"
{ $subsection parents }
{ $subsection each-parent }
{ $subsection find-parent }
"Adding children, removing children and performing certain other operations initiates relayout requests automatically. In other cases, relayout may have to be triggered explicitly. There is no harm from doing this several times in a row as consecutive relayout requests are coalesced."
{ $subsection relayout }
{ $subsection relayout-1 }
"Gadgets implement a generic word to inform their parents of their preferred size:"
{ $subsection pref-dim* }
"To get a gadget's preferred size, do not call the above word, instead use " { $link pref-dim  } ", which caches the result." ;

ARTICLE: "ui-null-layout" "Manual layouts"
"When automatic layout is not appropriate, gadgets can be added to a parent with no layout policy, and then positioned and sized manually by setting the " { $snippet "loc" } " field." ;

ARTICLE: "ui-layout-impl" "Implementing layout gadgets"
"The relayout process proceeds top-down, with parents laying out their children, which in turn lay out their children. Custom layout policy is implemented by defining a method on a generic word:"
{ $subsection layout* }
"When a " { $link layout* } " method is called, the size and location of the gadget has already been determined by its parent, and the method's job is to lay out the gadget's children. Children can be positioned and resized by setting a pair of slots, " { $snippet "loc" } " and " { $snippet "dim" } "." $nl
"Some assorted utility words which are useful for implementing layout logic:"
{ $subsection pref-dim }
{ $subsection pref-dims }
{ $subsection prefer }
{ $subsection max-dim }
{ $subsection dim-sum }
{ $warning
    "When implementing the " { $link layout* } " generic word for a gadget which inherits from another layout, the " { $link children-on } " word might have to be re-implemented as well."
    $nl
    "For example, suppose you want a " { $link grid } " layout which also displays a popup gadget on top. The implementation of " { $link children-on } " for the " { $link grid } " class determines which children of the grid are visible at one time, and this will never include your popup, so it will not be rendered, nor will it respond to gestures. The solution is to re-implement " { $link children-on } " on your class."
} ;

ARTICLE: "new-gadgets" "Implementing new gadgets"
"One of the goals of the Factor UI is to minimize the need to implement new types of gadgets by offering a highly reusable, orthogonal set of building blocks. However, in some cases implementing a new type of gadget is necessary, for example when writing a graphical visualization."
$nl
"Bare gadgets can be constructed directly, which is useful if all you need is a custom appearance with no further behavior (see " { $link "ui-pen-protocol" } "):"
{ $subsection <gadget> }
"New gadgets are defined as subclasses of an existing gadget type, perhaps even " { $link gadget } " itself. Direct subclasses of " { $link gadget } " can be constructed using " { $link new } ", however some subclasses may define their own parametrized constructors (see " { $link "parametrized-constructors" } ")."
$nl
"Further topics:"
{ $subsection "ui-gestures" }
{ $subsection "ui-paint" }
{ $subsection "ui-control-impl" }
{ $subsection "clipboard-protocol" }
{ $subsection "ui.gadgets.line-support" }
{ $see-also "ui-layout-impl" } ;

ARTICLE: "starting-ui" "Starting the UI"
"The main word of a vocabulary implementing a UI application should use a combinator to ensure that the application works when run from the command line as well as in the UI listener:"
{ $subsection with-ui } ;

ARTICLE: "ui" "UI framework"
"The " { $vocab-link "ui" } " vocabulary hierarchy implements the Factor UI framework. The implementation relies on a small amount of platform-specific code to open windows and receive keyboard and mouse events; UI gadgets are rendered using OpenGL."
{ $subsection "starting-ui" }
{ $subsection "ui-glossary" }
{ $subsection "building-ui" }
{ $subsection "new-gadgets" }
{ $subsection "ui-backend" } ;

ABOUT: "ui"
