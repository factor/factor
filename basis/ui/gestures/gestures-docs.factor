USING: hashtables help.markup help.syntax kernel strings system
ui.gadgets ui.gadgets.worlds ;
IN: ui.gestures

HELP: set-gestures
{ $values { "class" "a class word" } { "hash" hashtable } }
{ $description "Sets the gestures a gadget class responds to. The hashtable maps gestures to quotations with stack effect " { $snippet "( gadget -- )" } "." } ;

HELP: handle-gesture
{ $values { "gesture" "a gesture" } { "gadget" "the receiver of the gesture" } { "?" boolean } }
{ $contract "Handles a gesture sent to a gadget."
$nl
"Outputs " { $link f } " if the gesture was handled, and " { $link t } " if the gesture should be passed on to the gadget's parent."
$nl
"The default implementation looks at the " { $snippet "\"gestures\"" } " word property of each superclass of the gadget's class." }
{ $notes "Methods should be defined on this word if you desire to handle an arbitrary set of gestures. To define handlers for a fixed set, it is easier to use " { $link set-gestures } ". If you define a method on " { $snippet "handle-gesture" } ", you should also override " { $link handles-gesture? } "." } ;

HELP: handles-gesture?
{ $values { "gesture" "a gesture" } { "gadget" "the receiver of the gesture" } { "?" boolean } }
{ $contract "Returns a true value if " { $snippet "gadget" } " would handle " { $snippet "gesture" } " in its " { $link handle-gesture } " method."
$nl
"The default implementation looks at the " { $snippet "\"gestures\"" } " word property of each superclass of the gadget's class and returns true if a handler is present for " { $snippet "gesture" } "." }
{ $notes "This word is used in Factor's macOS UI to validate menu items." } ;

HELP: parents-handle-gesture?
{ $values { "gesture" "a gesture" } { "gadget" "the receiver of the gesture" } { "?" boolean } }
{ $contract "Returns a true value if " { $snippet "gadget" } " or any of its ancestors would handle " { $snippet "gesture" } " in its " { $link handle-gesture } " method." } ;

{ propagate-gesture handle-gesture handles-gesture? set-gestures } related-words

HELP: propagate-gesture
{ $values { "gesture" "a gesture" } { "gadget" gadget } }
{ $description "Calls " { $link handle-gesture } " on every parent of the " { $snippet "gadget" } ", starting with the " { $snippet "gadget" } " itself." } ;

HELP: motion
{ $class-description "Mouse motion gesture." }
{ $examples { $code "motion" } } ;

HELP: drag
{ $class-description "Mouse drag gesture. The " { $snippet "#" } " slot is either set to a mouse button number, or " { $link f } " indicating no specific button is expected." } ;

HELP: button-up
{ $class-description "Mouse button up gesture. Instances have two slots:"
    { $slots
        { "mods" { "a sequence of modifiers; see " { $link "keyboard-gestures" } } }
        { "#" { "a mouse button number, or " { $link f } " indicating no specific button is expected" } }
    }
}
{ $examples { $code "T{ button-up f f 1 }" "T{ button-up }" } } ;

HELP: button-down
{ $class-description "Mouse button down gesture. Instances have two slots:"
    { $slots
        { "mods" { "a sequence of modifiers; see " { $link "keyboard-gestures" } } }
        { "#" { "a mouse button number, or " { $link f } " indicating no specific button is expected" } }
    }
}
{ $examples { $code "T{ button-down f f 1 }" "T{ button-down }" } } ;

HELP: mouse-scroll
{ $class-description "Scroll wheel motion gesture. When this gesture is sent, the " { $link scroll-direction } " global variable is set to a direction vector." }
{ $examples { $code "mouse-scroll" } } ;

HELP: mouse-enter
{ $class-description "Gesture sent when the mouse enters the bounds of a gadget." }
{ $examples { $code "mouse-enter" } } ;

HELP: mouse-leave
{ $class-description "Gesture sent when the mouse leaves the bounds of a gadget." }
{ $examples { $code "mouse-leave" } } ;

HELP: gain-focus
{ $class-description "Gesture sent when a gadget gains keyboard focus." }
{ $examples { $code "gain-focus" } } ;

HELP: lose-focus
{ $class-description "Gesture sent when a gadget loses keyboard focus." }
{ $examples { $code "lose-focus" } } ;

HELP: cut-action
{ $class-description "Gesture sent when the " { $emphasis "cut" } " standard window system action is invoked." }
{ $examples { $code "cut-action" } } ;

HELP: copy-action
{ $class-description "Gesture sent when the " { $emphasis "copy" } " standard window system action is invoked." }
{ $examples { $code "copy-action" } } ;

HELP: paste-action
{ $class-description "Gesture sent when the " { $emphasis "paste" } " standard window system action is invoked." }
{ $examples { $code "paste-action" } } ;

HELP: delete-action
{ $class-description "Gesture sent when the " { $emphasis "delete" } " standard window system action is invoked." }
{ $examples { $code "delete-action" } } ;

HELP: select-all-action
{ $class-description "Gesture sent when the " { $emphasis "select all" } " standard window system action is invoked." }
{ $examples { $code "select-all-action" } } ;

HELP: new-action
{ $class-description "Gesture sent when the " { $emphasis "new" } " standard window system action is invoked." }
{ $examples { $code "new-action" } } ;

HELP: open-action
{ $class-description "Gesture sent when the " { $emphasis "open" } " standard window system action is invoked." }
{ $examples { $code "open-action" } } ;

HELP: save-action
{ $class-description "Gesture sent when the " { $emphasis "save" } " standard window system action is invoked." }
{ $examples { $code "save-action" } } ;

HELP: save-as-action
{ $class-description "Gesture sent when the " { $emphasis "save as" } " standard window system action is invoked." }
{ $examples { $code "save-as-action" } } ;

HELP: revert-action
{ $class-description "Gesture sent when the " { $emphasis "revert" } " standard window system action is invoked." }
{ $examples { $code "revert-action" } } ;

HELP: close-action
{ $class-description "Gesture sent when the " { $emphasis "close" } " standard window system action is invoked." }
{ $examples { $code "close-action" } } ;

HELP: C+
{ $description "Control key modifier." } ;

HELP: A+
{ $description "Alt key modifier. This is the Option key on macOS." } ;

HELP: M+
{ $description "Meta key modifier. This is the Command key on macOS and the Windows key on other Unix and Windows platforms." } ;

HELP: S+
{ $description "Shift key modifier." } ;

HELP: key-down
{ $class-description "Key down gesture. Instances have two slots:"
    { $slots
        { "mods" { "a sequence of modifiers; see " { $link "keyboard-gestures" } } }
        { "sym" { "a string denoting the key pressed; see " { $link "keyboard-gestures" } } }
    }
}
{ $examples { $code "T{ key-down f { C+ } \"a\" }" "T{ key-down f f \"TAB\" }" } } ;

HELP: key-up
{ $class-description "Key up gesture. Instances have two slots:"
    { $slots
        { "mods" { "a sequence of modifiers; see " { $link "keyboard-gestures" } } }
    { "sym" { "a string denoting the key pressed; see " { $link "keyboard-gestures" } } }
    }
}
{ $examples { $code "T{ key-up f { C+ } \"a\" }" "T{ key-up f f \"TAB\" }" } } ;

HELP: hand-gadget
{ $var-description "Global variable. The gadget at the mouse location." } ;

HELP: hand-loc
{ $var-description "Global variable. The mouse location relative to the top-left corner of the " { $link hand-world } "." } ;

{ hand-loc hand-rel } related-words

HELP: hand-clicked
{ $var-description "Global variable. The gadget at the location of the most recent click." } ;

HELP: hand-click-loc
{ $var-description "Global variable. The mouse location at the time of the most recent click relative to the top-left corner of the " { $link hand-world } "." } ;

{ hand-clicked hand-click-loc } related-words

HELP: hand-click#
{ $var-description "Global variable. The number of times the mouse was clicked in short succession. This counter is reset when " { $link double-click-timeout } " expires." } ;

HELP: hand-last-button
{ $var-description "Global variable. The mouse button most recently pressed." } ;

HELP: hand-last-time
{ $var-description "Global variable. The timestamp of the most recent mouse button click. This timestamp has the same format as the output value of " { $link nano-count } "." } ;

HELP: hand-buttons
{ $var-description "Global variable. A vector of mouse buttons currently held down." } ;

HELP: scroll-direction
{ $var-description "Global variable. If the most recent gesture was a " { $link mouse-scroll } ", this holds a pair of integers indicating the direction of the scrolling as a two-dimensional vector." } ;

HELP: double-click-timeout
{ $var-description "Global variable. The maximum delay between two button presses which will still increment " { $link hand-click# } "." } ;

HELP: button-gesture
{ $values { "gesture" "a gesture" } }
{ $description "Sends a gesture to the most recently clicked gadget, and if the gadget does not respond to the gesture, removes specific button number information from the gesture and sends it again." } ;

HELP: fire-motion
{ $description "Sends a " { $link motion } " or " { $link drag } " gesture to the gadget under the mouse, depending on whether a mouse button is being held down or not." } ;

HELP: forget-rollover
{ $description "Sends " { $link mouse-leave } " gestures to all gadgets containing the gadget under the mouse, and resets the " { $link hand-gadget } " variable." } ;

HELP: request-focus
{ $values { "gadget" gadget } }
{ $description "Gives keyboard focus to the " { $link focusable-child } " of the gadget. This may result in " { $link lose-focus } " and " { $link gain-focus } " gestures being sent." } ;

HELP: drag-loc
{ $values { "loc" "a pair of integers" } }
{ $description "Outputs the distance travelled by the mouse since the most recent press. Only meaningful inside a " { $link drag } " gesture handler." } ;

HELP: hand-rel
{ $values { "gadget" gadget } { "loc" "a pair of integers" } }
{ $description "Outputs the location of the mouse relative to the top-left corner of the gadget. Only meaningful inside a " { $link button-down } ", " { $link button-up } ", " { $link motion } " or " { $link drag } " gesture handler, where the gadget is contained in the same world as the gadget receiving the gesture." } ;

HELP: hand-click-rel
{ $values { "gadget" gadget } { "loc" "a pair of integers" } }
{ $description "Outputs the location of the last mouse relative to the top-left corner of the gadget. Only meaningful inside a " { $link button-down } ", " { $link button-up } ", " { $link motion } " or " { $link drag } " gesture handler, where the gadget is contained in the same world as the gadget receiving the gesture." } ;

HELP: under-hand
{ $values { "seq" "a new sequence" } }
{ $description "Outputs a sequence where the first element is the " { $link hand-world } " and the last is the " { $link hand-gadget } ", with all parents in between." } ;

HELP: gesture>string
{ $values { "gesture" "a gesture" } { "string/f" { $maybe string } } }
{ $contract "Creates a human-readable string from a gesture object, returning " { $link f } " if the gesture does not have a human-readable form." }
{ $examples
    { $unchecked-example "USING: io ui.gestures ;" "T{ key-down f { C+ } \"x\" } gesture>string print" "C+x" }
} ;

HELP: left-action
{ $class-description "Gesture sent when the user performs a multi-touch three-finger swipe left." } ;

HELP: right-action
{ $class-description "Gesture sent when the user performs a multi-touch three-finger swipe right." } ;

HELP: up-action
{ $class-description "Gesture sent when the user performs a multi-touch three-finger swipe up." } ;

HELP: down-action
{ $class-description "Gesture sent when the user performs a multi-touch three-finger swipe down." } ;

HELP: world-focus
{ $values { "world" world } { "gadget" gadget } }
{ $description "Gets the gadget that is in focus for the world." } ;

HELP: zoom-in-action
{ $class-description "Gesture sent when the user performs a multi-touch two-finger pinch in." } ;

HELP: zoom-out-action
{ $class-description "Gesture sent when the user performs a multi-touch two-finger pinch out." } ;

ARTICLE: "gesture-differences" "Gesture handling differences between platforms"
"On macOS, the modifier keys map as follows:"
{ $table
    { { $link S+ } "Shift" }
    { { $link A+ } "Option" }
    { { $link C+ } "Control" }
    { { $link M+ } "Command (Apple)" }
}
"On Windows and X11:"
{ $table
    { { $link S+ } "Shift" }
    { { $link A+ } "Alt" }
    { { $link C+ } "Control" }
    { { $link M+ } "Windows key (often called Super on Unix)" }
}
"On Windows, " { $link key-up } " gestures are not reported for all keyboard events."
$nl
{ $link "multitouch-gestures" } " are only supported on macOS."
$nl
{ $link "filedrop-gestures" } " are only supported on Windows." ;

ARTICLE: "ui-gestures" "UI gestures"
"User actions such as keyboard input and mouse button clicks deliver " { $emphasis "gestures" } " to gadgets. If the direct receiver of the gesture does not handle it, the gesture is passed on to the receiver's parent, and this way it travels up the gadget hierarchy. Gestures which are not handled at some point are ignored."
$nl
"There are two ways to define gesture handling logic. The simplest way is to associate a fixed set of gestures with a class:"
{ $subsections set-gestures }
"Another way is to define a generic word on a class which handles all gestures sent to gadgets of that class:"
{ $subsections handle-gesture }
"Sometimes a gesture needs to be presented to the user:"
{ $subsections gesture>string }
"Keyboard input:"
{ $subsections
    "ui-focus"
    "keyboard-gestures"
    "action-gestures"
    "ui-user-input"
}
"Mouse input:"
{ $subsections
    "mouse-gestures"
    "multitouch-gestures"
    "filedrop-gestures"
}
"Guidelines for cross-platform applications:"
{ $subsections "gesture-differences" }
"Abstractions built on top of gestures:"
{ $subsections
    "ui-commands"
    "ui-operations"
} ;

ARTICLE: "ui-focus" "Keyboard focus"
"The gadget with keyboard focus is the current receiver of keyboard gestures and user input. Gadgets that wish to receive keyboard input should request focus when clicked:"
{ $subsections request-focus }
"The following example demonstrates defining a handler for a mouse click gesture which requests focus:"
{ $code
    "my-gadget H{"
    "    { T{ button-down } [ request-focus ] }"
    "} set-gestures"
}
"To nominate a single child as the default focusable child, implement a method on a generic word:"
{ $subsections focusable-child* }
"Gestures are sent to a gadget when it gains or loses focus; this can be used to change the gadget's appearance, for example by displaying a border:"
{ $subsections
    gain-focus
    lose-focus
} ;

ARTICLE: "keyboard-gestures" "Keyboard gestures"
"There are two types of keyboard gestures:"
{ $subsections
    key-down
    key-up
}
"Each keyboard gesture has a set of modifiers and a key symbol. The set modifiers is denoted by an array which must either be " { $link f } ", or an order-preserving subsequence of the following:"
{ $code "{ S+ C+ A+ M+ }" }
{ $subsections
    S+
    C+
    A+
    M+
}
"A key symbol is either a single-character string denoting literal input, or one of the following strings:"
{ $list
  { $snippet "CLEAR" }
  { $snippet "RET" }
  { $snippet "ENTER" }
  { $snippet "ESC" }
  { $snippet "TAB" }
  { $snippet "BACKSPACE" }
  { $snippet "HOME" }
  { $snippet "DELETE" }
  { $snippet "END" }
  { $snippet "F1" }
  { $snippet "F2" }
  { $snippet "F3" }
  { $snippet "F4" }
  { $snippet "F5" }
  { $snippet "F6" }
  { $snippet "F7" }
  { $snippet "F8" }
  { $snippet "F9" }
  { $snippet "F10" }
  { $snippet "F11" }
  { $snippet "F12" }
  { $snippet "LEFT" }
  { $snippet "RIGHT" }
  { $snippet "DOWN" }
  { $snippet "UP" }
  { $snippet "PAGE_UP" }
  { $snippet "PAGE_DOWN" }
}
"The " { $link S+ } " modifier is only ever used with the above action keys; alphanumeric input input with the shift key is delivered without the " { $link S+ } " modifier set, instead the input itself is upper case. For example, the gesture corresponding to " { $snippet "s" } " with the Control and Shift keys pressed is presented as "
{ $code "T{ key-down f { C+ } \"S\" }" }
"The " { $snippet "RET" } " and " { $snippet "TAB" } " keys are never delivered in their literal form (" { $snippet "\"\\n\"" } " and " { $snippet "\"\\t\"" } ")." ;

ARTICLE: "ui-user-input" "Free-form keyboard input"
"Whereas keyboard gestures are intended to be used for keyboard shortcuts, certain gadgets such as text fields need to accept free-form keyboard input. This can be done by implementing a generic word:"
{ $subsections user-input* } ;

ARTICLE: "mouse-gestures" "Mouse gestures"
"There are two types of mouse gestures indicating button clicks:"
{ $subsections
    button-down
    button-up
}
"When a mouse button is pressed or released, two gestures are sent. The first gesture indicates the specific button number, and if this gesture is not handled, the second has a button number set to " { $link f } ":"
{ $code "T{ button-down f f 1 }" "T{ button-down f f f }" }
"Because tuple literals fill unspecified slots with " { $link f } ", the last gesture can be written as " { $snippet "T{ button-down }" } "."
$nl
"Gestures to indicate mouse motion, depending on whenever a button is held down or not:"
{ $subsections
    motion
    drag
}
"Gestures to indicate that the mouse has crossed gadget boundaries:"
{ $subsections
    mouse-enter
    mouse-leave
}
"A number of global variables are set after a mouse gesture is sent. These variables can be read to obtain additional information about the gesture."
{ $subsections
    hand-gadget
    hand-world
    hand-loc
    hand-buttons
    hand-clicked
    hand-click-loc
    hand-click#
}
"There are some utility words for working with click locations:"
{ $subsections
    hand-rel
    hand-click-rel
    drag-loc
}
"Mouse scroll wheel gesture:"
{ $subsections mouse-scroll }
"Global variable set when a mouse scroll wheel gesture is sent:"
{ $subsections scroll-direction } ;

ARTICLE: "multitouch-gestures" "Multi-touch gestures"
"Multi-touch gestures are only supported on macOS with newer MacBook and MacBook Pro models."
$nl
"Three-finger swipe:"
{ $subsections
    left-action
    right-action
    up-action
    down-action
}
"Two-finger pinch:"
{ $subsections
    zoom-in-action
    zoom-out-action
} ;

ARTICLE: "filedrop-gestures" "File drop gestures"
"File drop gestures are only supported on Windows. When user drags-and-drops a file or a group of files from another application, the following gesture can be handled:"
{ $subsections file-drop } ;

HELP: file-drop
{ $class-description "File drop gesture. The " { $slot "mods" } " slot contains the keyboard modifiers active at the time of the drop (see " { $link "keyboard-gestures" } "). The " { $link dropped-files } " global variable contains an array of full paths of the files that were dropped."
$nl
"The " { $link hand-loc } " global variable contains the drop location. If the user dropped files onto the non-client area of a window (the caption or the border), the gesture will not be triggered, but the contents of the " { $link dropped-files } " will be updated." }
{ $examples
"A typical gesture handler looks like this:
" { $snippet "your-gadget-class H{
    { T{ file-drop } [
        dropped-files get-global [ nip ] curry models:change-model
    ] }
} set-gestures" } } ;

HELP: dropped-files
{ $var-description "The global variable holds an array of full paths of the files that were dropped by the last " { $link file-drop } " gesture." } ;

ARTICLE: "action-gestures" "Action gestures"
"Action gestures exist to keep keyboard shortcuts for common application operations consistent."
{ $subsections
    undo-action
    redo-action
    cut-action
    copy-action
    paste-action
    delete-action
    select-all-action
    new-action
    open-action
    save-action
    save-as-action
    revert-action
    close-action
}
"The following keyboard gestures, if not handled directly by any gadget in the hierarchy until reaching the world, are re-sent as action gestures to the first gadget:"
{ $table
    { { $strong "Keyboard gesture" } { $strong "Action gesture" } }
    { { $snippet "T{ key-down f { C+ } \"z\" }" } { $snippet "undo-action" } }
    { { $snippet "T{ key-down f { C+ } \"y\" }" } { $snippet "redo-action" } }
    { { $snippet "T{ key-down f { C+ } \"x\" }" } { $snippet "cut-action" } }
    { { $snippet "T{ key-down f { C+ } \"c\" }" } { $snippet "copy-action" } }
    { { $snippet "T{ key-down f { C+ } \"v\" }" } { $snippet "paste-action" } }
    { { $snippet "T{ key-down f { C+ } \"a\" }" } { $snippet "select-all-action" } }
    { { $snippet "T{ key-down f { C+ } \"n\" }" } { $snippet "new-action" } }
    { { $snippet "T{ key-down f { C+ } \"o\" }" } { $snippet "open-action" } }
    { { $snippet "T{ key-down f { C+ } \"s\" }" } { $snippet "save-action" } }
    { { $snippet "T{ key-down f { C+ } \"S\" }" } { $snippet "save-as-action" } }
    { { $snippet "T{ key-down f { C+ } \"w\" }" } { $snippet "close-action" } }
}
"Action gestures should be used in place of the above keyboard gestures if possible. For example, on macOS, the standard " { $strong "Edit" } " menu items send action gestures." ;

ABOUT: "ui-gestures"
