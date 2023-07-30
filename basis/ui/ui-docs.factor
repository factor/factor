USING: classes colors debugger fonts help.markup help.syntax kernel
math.rectangles namespaces quotations sequences strings ui.backend
ui.gadgets ui.gadgets.books ui.gadgets.grids ui.gadgets.packs
ui.gadgets.private ui.gadgets.tracks ui.gadgets.worlds ui.private ui.text
vocabs.loader ;
IN: ui

HELP: close-window
{ $values { "gadget" gadget } }
{ $description "Close the native window containing " { $snippet "gadget" } "." } ;

HELP: open-window
{ $values { "gadget" gadget } { "title/attributes" { "a " { $link string } " or a " { $link world-attributes } " tuple" } } }
{ $description "Opens a native window containing " { $snippet "gadget" } " with the specified attributes. If a string is provided, it is used as the window title; otherwise, the window attributes are specified in a " { $link world-attributes } " tuple." } ;

HELP: resize-window
{ $values { "world" world } { "dim" "a pair of integers: width and height" } }
{ $description "Resize the native window so that its contents area (called the \"client area\" in Windows) has the specified dimensions." } ;

HELP: set-fullscreen
{ $values { "gadget" gadget } { "?" boolean } }
{ $description "Sets and unsets fullscreen mode for the gadget's world." } ;

HELP: set-up-window
{ $values { "world" world } }
{ $description "Initializes the window that shows the world." } ;

HELP: ui-thread
{ $var-description "Holds a reference to the running UI thread. This variable is used to ensure that there can only be one UI thread running at the same time." }
{ $see-also start-ui-thread } ;

HELP: ui-running?
{ $values { "?" boolean } }
{ $description "Whether the UI is running or not." } ;

HELP: worlds
{ $var-description "Global variable holding an association list mapping native window handles to " { $link world } " instances." } ;

{ worlds open-window find-window world-attributes } related-words

HELP: world-attributes
{ $values { "world-class" class } { "title" string } { "status" gadget } { "gadgets" sequence } { "pixel-format-attributes" sequence } { "window-controls" sequence } }
{ $class-description "Tuples of this class can be passed to " { $link open-window } " to control attributes of the window opened. The following attributes can be set:" }
{ $list
    { { $snippet "world-class" } " specifies the class of world to construct. " { $link world } " is the default." }
    { { $snippet "title" } " is the window title." }
    { { $snippet "status" } ", if specified, is a gadget that will be used as the window's status bar." }
    { { $snippet "gadgets" } " is a sequence of gadgets that will be placed inside the window." }
    { { $snippet "pixel-format-attributes" } " is a sequence of " { $link "ui.pixel-formats-attributes" } " that the window will request for its OpenGL pixel format." }
    { { $snippet "window-controls" } " is a sequence of " { $link "ui.gadgets.worlds-window-controls" } " that will be placed in the window." }
} ;

HELP: fullscreen?
{ $values { "gadget" gadget } { "?" boolean } }
{ $description "Queries the gadget's world to see if it is running in fullscreen mode." } ;

{ fullscreen? set-fullscreen } related-words

HELP: find-windows
{ $values { "quot" { $quotation ( world -- ? ) } } { "seq" sequence } }
{ $description "Finds all native windows such that the gadget passed to " { $link open-window } " satisfies the quotation, outputting an empty sequence if no such gadget could be found. The front-most native window is the last in the " { $snippet "seq" } "." } ;

HELP: find-window
{ $values { "quot" { $quotation ( world -- ? ) } } { "world/f" { $maybe world } } }
{ $description "Finds a native window such that the gadget passed to " { $link open-window } " satisfies the quotation, outputting " { $link f } " if no such gadget could be found. The front-most native window is checked first." } ;

HELP: register-window
{ $values { "world" world } { "handle" "a backend-specific handle" } }
{ $description "Adds a window to the global " { $link worlds } " variable." }
{ $notes "This word should only be called by the UI backend. User code can open new windows with " { $link open-window } "." } ;

HELP: unregister-window
{ $values { "handle" "a backend-specific handle" } }
{ $description "Removes a window from the global " { $link worlds } " variable." }
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
{ $values { "quot" { $quotation ( -- ) } } }
{ $description
  "Calls the quotation, starting the UI if necessary. If starting the UI is necessary, this word does not return and the UI will start after the quotation returns." $nl
  "While the combinator is running, " { $link ui-running? } " can be used by user code to determine whether it is running in a UI context or not."
}
{ $notes "This word should be used in the " { $link POSTPONE: MAIN: } " word of an application that uses the UI in order for the vocabulary to work when run from either the UI listener (" { $snippet "\"my-app\" run" } ") and the command line (" { $snippet "./factor -run=my-app" } ")." }
{ $examples "The " { $vocab-link "hello-ui" } " vocabulary implements a simple UI application which uses this word." } ;

HELP: beep
{ $description "Plays the system beep sound." } ;

HELP: system-alert
{ $values { "caption" string } { "text" string } }
{ $description "Displays an application-modal alert dialog box with the given caption and text." }
{ $notes "Since the window raised by this word is modal, all processing in all Factor threads will halt until the dialog is dismissed. In an application that makes full use of the UI framework, it would be more appropriate to display a pane gadget in a Factor window. This word is meant primarily to be used to display errors in deployed applications with minimal dependencies on the UI library, such as games." } ;

HELP: topmost-window
{ $values { "world" world } }
{ $description "Returns the " { $link world } " representing the currently focused window." } ;

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
{ $subsections gadget }
"Gadgets are arranged in a hierarchy, and all visible gadgets except for instances of " { $link world } " are contained in a parent gadget, stored in the " { $snippet "parent" } " slot."
{ $subsections
    "ui-geometry"
    "ui-layouts"
    "gadgets"
    "ui-worlds"
    "ui.gadgets.status-bar"
}
{ $see-also "models" } ;

ARTICLE: "gadgets" "Pre-made UI gadgets"
{ $subsections
    "ui.gadgets.labels"
    "ui.gadgets.borders"
    "ui.gadgets.labeled"
    "ui.gadgets.buttons"
    "ui.gadgets.sliders"
    "ui.gadgets.scrollers"
    "ui.gadgets.editors"
    "ui.gadgets.menus"
    "ui.gadgets.panes"
    "ui.gadgets.presentations"
    "ui.gadgets.tables"
} ;

ARTICLE: "ui-geometry" "Gadget geometry"
"The " { $link gadget } " class inherits from the " { $link rect } " class, and thus all gadgets have a bounding box:"
{ $subsections "math.rectangles" }
"Word for converting from a child gadget's coordinate system to a parent's:"
{ $subsections
    relative-loc
    screen-loc
}
"Hit testing:"
{ $subsections
    pick-up
    children-on
} ;

ARTICLE: "ui-worlds" "Top-level windows"
"Opening a top-level window:"
{ $subsections open-window }
"Finding top-level windows:"
{ $subsections find-window }
"Top-level windows are stored in a global variable:"
{ $subsections worlds }
"When a gadget is displayed in a top-level window, or added to a parent which is already showing in a top-level window, a generic word is called allowing the gadget to perform initialization tasks:"
{ $subsections graft* }
"When the gadget is removed from a parent shown in a top-level window, or when the top-level window is closed, a corresponding generic word is called to clean up:"
{ $subsections ungraft* }
"The root of the gadget hierarchy in a window is a special gadget which is rarely operated on directly, but it is helpful to know it exists:"
{ $subsections world }
"There is also syntax for defining window words, including a main window that is the entry point for a vocabulary:"
{ $subsections
    POSTPONE: WINDOW:
    POSTPONE: MAIN-WINDOW:
} ;

ARTICLE: "ui-backend" "Developing UI backends"
"None of the words documented in this section should be called directly by user code. They are only of interest when developing new UI backends."
{ $subsections
    "ui-backend-init"
    "ui-backend-windows"
}
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
{ $subsections start-ui }
"The " { $link (with-ui) } " word must not return until the event loop has stopped and the UI has been shut down." ;

ARTICLE: "ui-backend-windows" "UI backend window management"
"The high-level " { $link open-window } " word eventually calls a low-level word which you must implement:"
{ $subsections open-world-window }
"This word should create a native window, store some kind of handle in the " { $snippet "handle" } " slot, then call two words:"
{ $subsections register-window }
"The following words must also be implemented:"
{ $subsections
    set-title
    raise-window
}
"When a world needs to be redrawn, the UI will call a word automatically:"
{ $subsections draw-world }
"This word can also be called directly if the UI backend is notified by the window system that window contents have been invalidated. Before and after drawing, two words are called, which the UI backend must implement:"
{ $subsections
    select-gl-context
    flush-gl-context
}
"If the user clicks the window's close box, you must call the following word:"
{ $subsections close-window } ;

ARTICLE: "ui-layouts" "Gadget hierarchy and layouts"
"A layout gadget is a gadget whose sole purpose is to contain other gadgets. Layout gadgets position and resize children according to a certain policy, taking the preferred size of the children into account. Gadget hierarchies are constructed by building up nested layouts."
{ $subsections "ui-layout-basics" }
"Common layout gadgets:"
{ $subsections
    "ui-pack-layout"
    "ui-track-layout"
    "ui-grid-layout"
    "ui-frame-layout"
    "ui-book-layout"
}
"Advanced topics:"
{ $subsections
    "ui.gadgets.glass"
    "ui-null-layout"
    "ui-incremental-layout"
    "ui-layout-impl"
}
{ $see-also "ui.gadgets.borders" } ;

ARTICLE: "ui-layout-basics" "Layout basics"
"Gadgets are arranged in a hierarchy, and all visible gadgets except for instances of " { $link world } " are contained in a parent gadget."
$nl
"Managing the gadget hierarchy:"
{ $subsections
    add-gadget
    unparent
    add-gadgets
    clear-gadget
}
"The children of a gadget are available via the "
{ $snippet "children" } " slot."
$nl
"Working with gadget children:"
{ $subsections
    gadget-child
    nth-gadget
    each-child
    child?
}
"Working with gadget parents:"
{ $subsections
    parents
    each-parent
    find-parent
}
"Adding children, removing children and performing certain other operations initiates relayout requests automatically. In other cases, relayout may have to be triggered explicitly. There is no harm from doing this several times in a row as consecutive relayout requests are coalesced."
{ $subsections
    relayout
    relayout-1
}
"Gadgets implement a generic word to inform their parents of their preferred size:"
{ $subsections pref-dim* }
"To get a gadget's preferred size, do not call the above word, instead use " { $link pref-dim } ", which caches the result." ;

ARTICLE: "ui-null-layout" "Manual layouts"
"When automatic layout is not appropriate, gadgets can be added to a parent with no layout policy, and then positioned and sized manually by setting the " { $snippet "loc" } " field." ;

ARTICLE: "ui-layout-impl" "Implementing layout gadgets"
"The relayout process proceeds top-down, with parents laying out their children, which in turn lay out their children. Custom layout policy is implemented by defining a method on a generic word:"
{ $subsections layout* }
"When a " { $link layout* } " method is called, the size and location of the gadget has already been determined by its parent, and the method's job is to lay out the gadget's children. Children can be positioned and resized by setting a pair of slots, " { $snippet "loc" } " and " { $snippet "dim" } "." $nl
"Some assorted utility words which are useful for implementing layout logic:"
{ $subsections
    pref-dim
    pref-dims
    prefer
    max-dims
    sum-dims
}
{ $warning
    "When implementing the " { $link layout* } " generic word for a gadget which inherits from another layout, the " { $link children-on } " word might have to be re-implemented as well."
    $nl
    "For example, suppose you want a " { $link grid } " layout which also displays a popup gadget on top. The implementation of " { $link children-on } " for the " { $link grid } " class determines which children of the grid are visible at one time, and this will never include your popup, so it will not be rendered, nor will it respond to gestures. The solution is to re-implement " { $link children-on } " on your class."
} ;

ARTICLE: "new-gadgets" "Implementing new gadgets"
"One of the goals of the Factor UI is to minimize the need to implement new types of gadgets by offering a highly reusable, orthogonal set of building blocks. However, in some cases implementing a new type of gadget is necessary, for example when writing a graphical visualization."
$nl
"Bare gadgets can be constructed directly, which is useful if all you need is a custom appearance with no further behavior (see " { $link "ui-pen-protocol" } "):"
{ $subsections <gadget> }
"New gadgets are defined as subclasses of an existing gadget type, perhaps even " { $link gadget } " itself. Direct subclasses of " { $link gadget } " can be constructed using " { $link new } ", however some subclasses may define their own parameterized constructors (see " { $link "parameterized-constructors" } ")."
$nl
"Further topics:"
{ $subsections
    "ui-gestures"
    "ui-paint"
    "ui-control-impl"
    "clipboard-protocol"
    "ui.gadgets.line-support"
}
{ $see-also "ui-layout-impl" } ;

ARTICLE: "starting-ui" "Starting the UI"
"The main word of a vocabulary implementing a UI application should use a combinator to ensure that the application works when run from the command line as well as in the UI listener:"
{ $subsections with-ui } ;

ARTICLE: "ui" "UI framework"
"The " { $vocab-link "ui" } " vocabulary hierarchy implements the Factor UI framework. The implementation relies on a small amount of platform-specific code to open windows and receive keyboard and mouse events; UI gadgets are rendered using OpenGL."
{ $subsections
    "starting-ui"
    "ui-glossary"
    "building-ui"
    "new-gadgets"
    "ui-backend"
} ;

ABOUT: "ui"

HELP: close-button
{ $description "Asks for a close button to be available for a window. Without a close button, a window cannot be closed by the user and must be closed by the program using " { $link close-window } "." } ;

HELP: minimize-button
{ $description "Asks for a minimize button to be available for a window." } ;

HELP: maximize-button
{ $description "Asks for a maximize button to be available for a window." } ;

HELP: resize-handles
{ $description "Asks for resize controls to be available for a window. Without resize controls, the window size will not be changeable by the user." } ;

HELP: small-title-bar
{ $description "Asks for a window to have a small title bar. Without a title bar, the " { $link close-button } ", " { $link minimize-button } ", and " { $link maximize-button } " controls will not be available. A small title bar may have other side effects in the window system, such as causing the window to not show up in the system task switcher and to float over other Factor windows." } ;

HELP: normal-title-bar
{ $description "Asks for a window to have a title bar. Without a title bar, the " { $link close-button } ", " { $link minimize-button } ", and " { $link maximize-button } " controls will not be available." } ;

HELP: textured-background
{ $description "Asks for a window to have a background that blends seamlessly with the window frame. Factor will leave the window background transparent and pass mouse button gestures not handled directly by a gadget through to the window system so that the window can be dragged from anywhere on its background." } ;

HELP: dialog-window
{ $description "Provides a hint to the window manager to create a floating, dialog-style window. Currently, this is only implemented for the GTK backend." } ;

HELP: WINDOW:
{ $syntax "WINDOW: window-word { attributes }
    attribute-code ;" }
{ $description "Defines a word for the current vocabulary named " { $snippet "window-word" } " that opens a UI window when run. The " { $snippet "attributes" } " specify the key-value pairs of the window's " { $link world-attributes } ". The " { $snippet "attribute-code" } " is run with the " { $snippet "world-attributes" } " on the stack; this allows the word to construct gadget objects to place in the " { $snippet "gadget" } " slot or set other runtime-dependent world attributes." }
{ $examples
"From the " { $vocab-link "hello-ui" } " vocabulary. Creates a window with the title \"Hi\" containing a label reading \"Hello world\":"
{ $code
"USING: accessors ui ui.gadgets.labels ;
IN: hello-ui

WINDOW: hello { { title \"Hi\" } }
    \"Hello world\" <label> >>gadgets ;"
} } ;

HELP: MAIN-WINDOW:
{ $syntax "MAIN-WINDOW: window-word { attributes }
    attribute-code ;" }
{ $description "Defines a " { $link POSTPONE: MAIN: } " word for the current vocabulary named " { $snippet "window-word" } " that opens a UI window when the vocabulary is " { $link run } ". The " { $snippet "attributes" } " specify the key-value pairs of the window's " { $link world-attributes } ". The " { $snippet "attribute-code" } " is run with the " { $snippet "world-attributes" } " on the stack; this allows the word to construct gadget objects to place in the " { $snippet "gadget" } " slot or set other runtime-dependent world attributes." }
{ $examples
"From the " { $vocab-link "hello-ui" } " vocabulary. Creates a window with the title \"Hi\" containing a label reading \"Hello world\":"
{ $code
"USING: accessors ui ui.gadgets.labels ;
IN: hello-ui

MAIN-WINDOW: hello { { title \"Hi\" } }
    \"Hello world\" <label> >>gadgets ;"
} } ;

{ POSTPONE: WINDOW: POSTPONE: MAIN-WINDOW: } related-words

ARTICLE: "ui.gadgets.worlds-window-controls" "Window controls"
"The following window controls can be placed in a " { $link world } " window:"
{ $subsections
    close-button
    minimize-button
    maximize-button
    resize-handles
    small-title-bar
    normal-title-bar
    textured-background
    dialog-window
}
"Provide a sequence of these values in the " { $snippet "window-controls" } " slot of the " { $link world-attributes } " tuple you pass to " { $link open-window } "." ;
