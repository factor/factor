USING: ui.gadgets.worlds ui.gadgets ui.backend help.markup
help.syntax strings quotations debugger io.styles namespaces
ui.gadgets.tracks ui.gadgets.packs ui.gadgets.grids
ui.gadgets.frames ui.gadgets.books ui.gadgets.panes
ui.gadgets.incremental ;
IN: ui

HELP: windows
{ $var-description "Global variable holding an association list mapping native window handles to " { $link world } " instances." } ;

{ windows open-window find-window } related-words

HELP: open-window
{ $values { "gadget" gadget } { "title" string } }
{ $description "Opens a native window with the specified title." } ;

HELP: find-window
{ $values { "quot" "a quotation with stack effect " { $snippet "( world -- ? )" } } { "world" "a " { $link world } " or " { $link f } } }
{ $description "Finds a native window whose world satisfies the quotation, outputting " { $link f } " if no such world could be found. The front-most native window is checked first." } ;

HELP: start-world
{ $values { "world" world } }
{ $description "Starts a world." }
{ $notes "This word should be called by the UI backend after " { $link register-window } ", but before making the world's containing window visible on the screen." } ;

HELP: register-window
{ $values { "world" world } { "handle" "a baackend-specific handle" } }
{ $description "Adds a window to the global " { $link windows } " variable." }
{ $notes "This word should only be called by the UI backend.  User code can open new windows with " { $link open-window } "." } ;

HELP: unregister-window
{ $values { "handle" "a baackend-specific handle" } }
{ $description "Removes a window from the global " { $link windows } " variable." }
{ $notes "This word should only be called only by the UI backend, and not user code." } ;

HELP: ui
{ $description "Starts the Factor UI." } ;

HELP: start-ui
{ $description "Called by the UI backend to initialize the platform-independent parts of UI. This word should be called after the backend is ready to start displaying new windows, and before the event loop starts." } ;

HELP: (open-world-window)
{ $values { "world" world } }
{ $description "Opens a native window containing the given world. This grafts the world by calling " { $link graft } ". Each world can only be displayed in one top-level window at a time." }
{ $notes "This word should not be called directly by user code. Instead, use " { $link open-window } "." } ;

HELP: ui-try
{ $values { "quot" quotation } }
{ $description "Calls the quotation. If it throws an error, opens a window with the error and restores the data stack." }
{ $notes "This is essentially a graphical variant of " { $link try } "." } ;

HELP: stop-world
{ $values { "world" world } }
{ $description "Stops a world." }
{ $notes "This word should only be called by the UI backend, and not user code." } ;

ARTICLE: "ui-glossary" "UI glossary"
{ $table
    { "color specifier"
        { "an array of four elements, all numbers between 0 and 1:"
            { $list
                "red"
                "green"
                "blue"
                "alpha - 0 is completely transparent, 1 is completely opaque"
            }
        }
    }
    { "dimension" "a pair of integers denoting pixel size on screen" }
    { "font specifier"
        { "an array of three elements:"
            { $list
                { "font family - one of " { $snippet "serif" } ", " { $snippet "sans-serif" } " or " { $snippet "monospace" } }
                { "font style - one of " { $link plain } ", " { $link bold } ", " { $link italic } " or " { $link bold-italic } }
                "font size in points"
            }
        }
    }
    { "gadget" { "a graphical element which responds to user input. Gadgets are tuples which (directly or indirectly) delegate to " { $link gadget } " instances." } }
    { "label specifier" { "a string, " { $link f } " or a gadget. See " { $link "ui.gadgets.buttons" } } }
    { "orientation specifier" { "one of " { $snippet "{ 0 1 }" } " or " { $snippet "{ 1 0 }" } ", with the former denoting vertical orientation and the latter denoting horizontal. Using a vector instead of symbolic constants allows these values to be directly useful in co-ordinate calculations" } }
    { "point" "a pair of integers denoting a pixel location on screen" }
} ;

ARTICLE: "building-ui" "Building user interfaces"
"A gadget is a graphical element which responds to user input. Gadgets are implemented as tuples which (directly or indirectly) delegate to instances of " { $link gadget } ", which in turn delegates to " { $link rect } "."
{ $subsection gadget }
"Gadgets are arranged in a hierarchy, and all visible gadgets except for instances of " { $link world } " are contained in a parent gadget, stored in the " { $link gadget-parent } " slot."
{ $subsection "ui-geometry" }
{ $subsection "ui-layouts" }
{ $subsection "gadgets" }
{ $subsection "models" }
{ $subsection "ui-windows" } ;

ARTICLE: "gadgets" "Pre-made UI gadgets"
{ $subsection "ui.gadgets.labels" }
{ $subsection "gadgets-polygons" }
{ $subsection "ui.gadgets.borders" }
{ $subsection "ui.gadgets.labelled" }
{ $subsection "ui.gadgets.buttons" }
{ $subsection "ui.gadgets.sliders" }
{ $subsection "ui.gadgets.scrollers" }
{ $subsection "gadgets-editors" }
{ $subsection "ui.gadgets.panes" }
{ $subsection "ui.gadgets.presentations" }
{ $subsection "ui.gadgets.lists" } ;

ARTICLE: "ui-geometry" "Gadget geometry"
"Instances of " { $link gadget } " (and thus all gadgets) delegate to rectangles which specify the gadget's bounding box:"
{ $subsection rect }
"Rectangles can be taken apart:"
{ $subsection rect-loc }
{ $subsection rect-dim }
{ $subsection rect-bounds }
{ $subsection rect-extent }
"New rectangles can be created:"
{ $subsection <zero-rect> }
{ $subsection <rect> }
{ $subsection <extent-rect> }
"More utility words for working with rectangles:"
{ $subsection offset-rect }
{ $subsection rect-intersect }
{ $subsection intersects? }
"A gadget's bounding box is always relative to its parent:"
{ $subsection gadget-parent }
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
"An UI backend is required to define a word to start the UI:"
{ $subsection ui }
"This word should contain backend initialization, together with some boilerplate:"
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
"The " { $link ui } " word must not return until the event loop has stopped and the UI has been shut down."
$nl
"The event loop must not block. Instead, it should poll for pending events, then call " { $link ui-step } ", which performs pending layout, runs timers and sleeps for 10 milliseconds, or until a Factor thread wakes up." ;

ARTICLE: "ui-backend-windows" "UI backend window management"
"The high-level " { $link open-window } " word eventually calls a low-level word which you must implement:"
{ $subsection open-world-window }
"This word should create a native window, store some kind of handle in the " { $link world-handle } " slot, then call two words:"
{ $subsection register-window }
{ $subsection start-world }
"The following words must also be implemented:"
{ $subsection set-title }
{ $subsection raise-window }
"When a world needs to be redrawn, the UI will call a word automatically:"
{ $subsection draw-world }
"This word can also be called directly if the UI backend is notified by the window system that window contents have been invalidated. Before and after drawing, two words are called, which the UI backend must implement:"
{ $subsection select-gl-context }
{ $subsection flush-gl-context }
"If the user clicks the window's close box, you must call the following two words in sequence:"
{ $subsection stop-world }
{ $subsection unregister-window } ;

ARTICLE: "ui-layouts" "Gadget hierarchy and layouts"
"A layout gadget is a gadget whose sole purpose is to contain other gadgets. Layout gadgets position and resize children according to a certain policy, taking the preferred size of the children into account. Gadget hierarchies are constructed by building up nested layouts."
{ $subsection "ui-layout-basics" }
{ $subsection "ui-layout-combinators" }
"Common layout gadgets:"
{ $subsection "ui-pack-layout" }
{ $subsection "ui-track-layout" }
{ $subsection "ui-grid-layout" }
{ $subsection "ui-frame-layout" }
{ $subsection "ui-book-layout" }
"Advanced topics:"
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
"Working with gadget children:"
{ $subsection gadget-children }
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
"To get a gadget's preferred size, do not call the above word, instead use " { $link pref-dim  } ",  which caches the result." ;

ARTICLE: "ui-layout-combinators" "Creating layouts using combinators"
"The " { $link make } " combinator provides a convenient way of constructing sequences by keeping the intermediate sequence off the stack until construction is done. The " { $link , } " and " { $link % } " words operate on this implicit sequence, reducing stack noise."
$nl
"Similar tools exist for constructing complex gadget hierarchies. Different words are used for different types of gadgets; see " { $link "ui-pack-layout" } ", " { $link "ui-track-layout" } " and " { $link "ui-frame-layout" } " for specifics. This section documents their common factors."
$nl
"Gadget construction combinators whose names are prefixed with " { $snippet "make-" } " construct new gadgets and push them on the stack. The primitive combinator used to define all combinators of this form:"
{ $subsection make-gadget }
"Words such as " { $link gadget, } " and " { $link track, } " access the gadget through the " { $link make-gadget } " variable."
$nl
"Combinators whose names are prefixed with " { $snippet "build-" } " take a tuple as input, and construct a new gadget which the tuple will delegate to. The primitive combinator used to define all combinators of this form:"
{ $subsection build-gadget }
"In this case, the new gadget is stored in both the " { $link make-gadget } " and " { $link gadget } " variables."
$nl
"A combinator which stores a gadget in the " { $link gadget } " variable; it is used by " { $link build-gadget } ":"
{ $subsection with-gadget }
"The following words access the " { $link gadget } " variable; they can be used from " { $link with-gadget } " and " { $link build-gadget } " to store child gadgets in tuple slots:"
{ $subsection g }
{ $subsection g-> } ;

ARTICLE: "ui-pack-layout" "Pack layouts"
"Pack gadgets layout their children along a single axis."
{ $subsection pack }
"Creating empty packs:"
{ $subsection <pack> }
{ $subsection <pile> }
{ $subsection <shelf> }
"Creating packs using a combinator:"
{ $subsection make-pile }
{ $subsection make-filled-pile }
{ $subsection make-shelf }
{ $subsection gadget, }
"For more control, custom layouts can reuse portions of pack layout logic:"
{ $subsection pack-pref-dim }
{ $subsection pack-layout } ;

ARTICLE: "ui-track-layout" "Track layouts"
"Track gadgets are like " { $link "ui-pack-layout" } " except each child is resized to a fixed multiple of the track's dimension."
{ $subsection track }
"Creating empty tracks:"
{ $subsection <track> }
"Adding children:"
{ $subsection track-add }
"Creating new tracks using a combinator:"
{ $subsection make-track }
{ $subsection build-track }
{ $subsection track, }
"New gadgets can be defined which delegate to tracks for layout:"
{ $subsection build-track } ;

ARTICLE: "ui-grid-layout" "Grid layouts"
"Grid gadgets layout their children in a rectangular grid."
{ $subsection grid }
"Creating grids from a fixed set of gadgets:"
{ $subsection <grid> }
"Managing chidren:"
{ $subsection grid-add }
{ $subsection grid-remove }
{ $subsection grid-child } ;

ARTICLE: "ui-frame-layout" "Frame layouts"
"Frames resemble " { $link "ui-grid-layout" } " except the size of grid is fixed at 3x3, and the center gadget fills up any available space. Because frames delegate to grids, grid layout words can be used to add and remove children."
{ $subsection frame }
"Creating empty frames:"
{ $subsection <frame> }
"Creating new frames using a combinator:"
{ $subsection make-frame }
{ $subsection build-frame }
{ $subsection frame, }
"New gadgets can be defined which delegate to frames for layout:"
{ $subsection build-frame }
"A set of mnemonic words for the positions on a frame's 3x3 grid; these words push values which may be passed to " { $link grid-add } " or " { $link frame, } ":"
{ $subsection @center }
{ $subsection @left }
{ $subsection @right }
{ $subsection @top }
{ $subsection @bottom }
{ $subsection @top-left }
{ $subsection @top-right }
{ $subsection @bottom-left }
{ $subsection @bottom-right } ;

ARTICLE: "ui-book-layout" "Book layouts"
"Books can contain any number of children, and display one child at a time."
{ $subsection book }
{ $subsection <book> } ;

ARTICLE: "ui-null-layout" "Manual layouts"
"When automatic layout is not appropriate, gadgets can be added to a parent with no layout policy, and then positioned and sized manually:"
{ $subsection set-rect-loc }
{ $subsection set-gadget-dim } ;

ARTICLE: "ui-incremental-layout" "Incremental layouts"
"Incremental layout gadgets are like " { $link "ui-pack-layout" } " except the relayout operation after adding a new child can be done in constant time."
$nl
"With all layouts, relayout requests from consecutive additions and removals are of children are coalesced and result in only one relayout operation being performed, however the run time of the relayout operation itself depends on the number of children."
$nl
"Incremental layout is used by " { $link pane } " gadgets to ensure that new lines of output does not take longer to display when the pane already has previous output."
$nl
"Incremental layouts are not a general replacement for " { $link "ui-pack-layout" } " and there are some limitations to be aware of."
{ $subsection incremental }
{ $subsection <incremental> }
"Children are added and removed with a special set of words which perform necessary relayout immediately:"
{ $subsection add-incremental }
{ $subsection clear-incremental }
"Calling " { $link unparent } " to remove a child of an incremental layout is permitted, however the relayout following the removal will not be performed in constant time, because all gadgets following the removed gadget need to be moved." ;

ARTICLE: "ui-layout-impl" "Implementing layout gadgets"
"The relayout process proceeds top-down, with parents laying out their children, which in turn lay out their children. Custom layout policy is implemented by defining a method on a generic word:"
{ $subsection layout* }
"When a " { $link layout* } " method is called, the size and location of the gadget has already been determined by its parent, and the method's job is to lay out the gadget's children. Children can be positioned and resized with a pair of words:"
{ $subsection set-rect-loc }
{ $subsection set-layout-dim }
"Some assorted utility words which are useful for implementing layout logic:"
{ $subsection pref-dim }
{ $subsection pref-dims }
{ $subsection prefer }
{ $subsection max-dim }
{ $subsection dim-sum }
{ $warning
    "When implementing the " { $link layout* } " generic word for a gadget which intends to delegate to another layout, the " { $link children-on } " word might have to be re-implemented as well."
    $nl
    "For example, suppose you want a " { $link grid } " layout which also displays a popup gadget on top. The implementation of " { $link children-on } " for the " { $link grid } " class determines which children of the grid are visible at one time, and this will never include your popup, so it will not be rendered, nor will it respond to gestures. The solution is to re-implement " { $link children-on } " on your class."
} ;

ARTICLE: "new-gadgets" "Implementing new gadgets"
"One of the goals of the Factor UI is to minimize the need to implement new types of gadgets by offering a highly reusable, orthogonal set of building blocks. However, in some cases implementing a new type of gadget is necessary, for example when writing a graphical visualization."
$nl
"Bare gadgets can be constructed directly, which is useful if all you need is a custom appearance with no further behavior (see " { $link "ui-pen-protocol" } "):"
{ $subsection <gadget> }
"You can construct a new tuple which delegates to a bare gadget:"
{ $subsection construct-gadget }
"You can also delegate a tuple to an existing gadget:"
{ $subsection set-gadget-delegate }
"Further topics:"
{ $subsection "ui-gestures" }
{ $subsection "ui-paint" }
{ $subsection "ui-control-impl" }
{ $subsection "clipboard-protocol" }
{ $subsection "timers" }
{ $see-also "ui-layout-impl" } ;

ARTICLE: "ui" "UI framework"
{ $subsection "ui-glossary" }
{ $subsection "building-ui" }
{ $subsection "new-gadgets" }
{ $subsection "ui-backend" } ;

ABOUT: "ui"
