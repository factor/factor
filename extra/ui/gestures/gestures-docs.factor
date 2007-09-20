USING: ui.gadgets help.markup help.syntax hashtables
strings kernel system ;
IN: ui.gestures

HELP: set-gestures
{ $values { "class" "a class word" } { "hash" hashtable } }
{ $description "Sets the gestures a gadget class responds to. The hashtable maps gestures to quotations with stack effect " { $snippet "( gadget -- )" } "." } ;

HELP: handle-gesture*
{ $values { "gadget" "the receiver of the gesture" } { "gesture" "a gesture" } { "delegate" "an object" } { "?" "a boolean" } }
{ $contract "Handles a gesture sent to a gadget. As the delegation chain is traversed, this generic word is called with every delegate of the gadget at the top of the stack, however the front-most delegate remains fixed as the " { $snippet "gadget" } " parameter."
$nl
"Outputs " { $link f } " if the gesture was handled, and " { $link t } " if the gesture should be passed on to the gadget's delegate." }
{ $notes "Methods should be defined on this word if you desire to handle an arbitrary set of gestures. To define handlers for a fixed set, it is easier to use " { $link set-gestures } "." } ;

HELP: handle-gesture
{ $values { "gesture" "a gesture" } { "gadget" gadget } { "?" "a boolean" } }
{ $description "Calls " { $link handle-gesture* } " on every delegate of " { $snippet "gadget" } ". Outputs " { $link f } " if some delegate handled the gesture, else outputs " { $link t } "." } ;

{ send-gesture handle-gesture handle-gesture* set-gestures } related-words

HELP: send-gesture
{ $values { "gesture" "a gesture" } { "gadget" gadget } { "?" "a boolean" } }
{ $description "Calls " { $link send-gesture } " on every parent of " { $snippet "gadget" } ". Outputs " { $link f } " if some parent handled the gesture, else outputs " { $link t } "." } ;

HELP: user-input
{ $values { "str" string } { "gadget" gadget } }
{ $description "Calls " { $link user-input* } " on every parent of the gadget." } ;

HELP: motion
{ $class-description "Mouse motion gesture." }
{ $examples { $code "T{ motion }" } } ;

HELP: drag
{ $class-description "Mouse drag gesture. The " { $link drag-# } " slot is either set to a mouse button number, or " { $link f } " indicating no specific button is expected." } ;

HELP: button-up
{ $class-description "Mouse button up gesture. Instances have two slots:"
    { $list
        { { $link button-up-mods } " - a sequence of modifiers; see " { $link "keyboard-gestures" } }
        { { $link button-up-# } " - a mouse button number, or " { $link f } " indicating no specific button is expected" }
    }
}
{ $examples { $code "T{ button-up f f 1 }" "T{ button-up }" } } ;

HELP: button-down
{ $class-description "Mouse button down gesture. Instances have two slots:"
    { $list
        { { $link button-down-mods } " - a sequence of modifiers; see " { $link "keyboard-gestures" } }
        { { $link button-down-# } " - a mouse button number, or " { $link f } " indicating no specific button is expected" }
    }
}
{ $examples { $code "T{ button-down f f 1 }" "T{ button-down }" } } ;

HELP: mouse-scroll
{ $class-description "Scroll wheel motion gesture. When this gesture is sent, the " { $link scroll-direction } " global variable is set to a direction vector." }
{ $examples { $code "T{ mouse-scroll }" } } ;

HELP: mouse-enter
{ $class-description "Gesture sent when the mouse enters the bounds of a gadget." }
{ $examples { $code "T{ mouse-enter }" } } ;

HELP: mouse-leave
{ $class-description "Gesture sent when the mouse leaves the bounds of a gadget." }
{ $examples { $code "T{ mouse-leave }" } } ;

HELP: gain-focus
{ $class-description "Gesture sent when a gadget gains keyboard focus." }
{ $examples { $code "T{ gain-focus }" } } ;

HELP: lose-focus
{ $class-description "Gesture sent when a gadget loses keyboard focus." }
{ $examples { $code "T{ lose-focus }" } } ;

HELP: cut-action
{ $class-description "Gesture sent when the " { $emphasis "cut" } " standard window system action is invoked." }
{ $examples { $code "T{ cut-action }" } } ;

HELP: copy-action
{ $class-description "Gesture sent when the " { $emphasis "copy" } " standard window system action is invoked." }
{ $examples { $code "T{ copy-action }" } } ;

HELP: paste-action
{ $class-description "Gesture sent when the " { $emphasis "paste" } " standard window system action is invoked." }
{ $examples { $code "T{ paste-action }" } } ;

HELP: delete-action
{ $class-description "Gesture sent when the " { $emphasis "delete" } " standard window system action is invoked." }
{ $examples { $code "T{ delete-action }" } } ;

HELP: select-all-action
{ $class-description "Gesture sent when the " { $emphasis "select all" } " standard window system action is invoked." }
{ $examples { $code "T{ select-all-action }" } } ;

HELP: generalize-gesture
{ $values { "gesture" "a gesture" } { "newgesture" "a new gesture" } }
{ $description "Turns a " { $link button-down } ", " { $link button-up } " or " { $link drag } " action naming a specific mouse button into one which can apply regardless of which mouse button was pressed." } ;

HELP: C+
{ $description "Control key modifier." } ;

HELP: A+
{ $description "Alt key modifier." } ;

HELP: M+
{ $description "Meta key modifier. This is the Command key on Mac OS X." } ;

HELP: S+
{ $description "Shift key modifier." } ;

HELP: key-down
{ $class-description "Key down gesture. Instances have two slots:"
    { $list
        { { $link key-down-mods } " - a sequence of modifiers; see " { $link "keyboard-gestures" } }
    { { $link key-down-sym } " - a string denoting the key pressed; see " { $link "keyboard-gestures" } }
    }
}
{ $examples { $code "T{ key-down f { C+ } \"a\" }" "T{ key-down f f \"TAB\" }" } } ;

HELP: key-up
{ $class-description "Key up gesture. Instances have two slots:"
    { $list
        { { $link key-up-mods } " - a sequence of modifiers; see " { $link "keyboard-gestures" } }
    { { $link key-up-sym } " - a string denoting the key pressed; see " { $link "keyboard-gestures" } }
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
{ $var-description "Global variable. The timestamp of the most recent mouse button click. This timestamp has the same format as the output value of " { $link millis } "." } ;

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
{ $values { "gesture" "a gesture" } { "string/f" "a " { $link string } " or " { $link f } } }
{ $contract "Creates a human-readable string from a gesture object, returning " { $link f } " if the gesture does not have a human-readable form." }
{ $examples
    { $example "USE: ui.gestures" "T{ key-down f { C+ } \"x\" } gesture>string print" "C+x" }
} ;

ARTICLE: "ui-gestures" "UI gestures"
"User actions such as keyboard input and mouse button clicks deliver " { $emphasis "gestures" } " to gadgets. If the direct receiver of the gesture does not handle it, the gesture is passed on to the receiver's parent, and this way it travels up the gadget hierarchy. Gestures which are not handled at some point are ignored."
$nl
"There are two ways to define gesture handling logic. The simplest way is to associate a fixed set of gestures with a class:"
{ $subsection set-gestures }
"Another way is to define a generic word on a class which handles all gestures sent to gadgets of that class:"
{ $subsection handle-gesture* }
"Sometimes a gesture needs to be presented to the user:"
{ $subsection gesture>string }
"Keyboard input:"
{ $subsection "ui-focus" }
{ $subsection "keyboard-gestures" }
{ $subsection "action-gestures" }
{ $subsection "ui-user-input" }
"Mouse input:"
{ $subsection "mouse-gestures" }
"Abstractions built on top of gestures:"
{ $subsection "ui-commands" }
{ $subsection "ui-operations" } ;

ARTICLE: "ui-focus" "Keyboard focus"
"The gadget with keyboard focus is the current receiver of keyboard gestures and user input. Gadgets that wish to receive keyboard input should request focus when clicked:"
{ $subsection request-focus }
"The following example demonstrates defining a handler for a mouse click gesture which requests focus:"
{ $code
    "my-gadget H{"
    "    { T{ button-down } [ request-focus ] }"
    "} set-gestures"
}
"To nominate a single child as the default focusable child, implement a method on a generic word:"
{ $subsection focusable-child* }
"Gestures are sent to a gadget when it gains or loses focus; this can be used to change the gadget's appearance, for example by displaying a border:"
{ $subsection gain-focus }
{ $subsection lose-focus } ;

ARTICLE: "keyboard-gestures" "Keyboard gestures"
"There are two types of keyboard gestures:"
{ $subsection key-down }
{ $subsection key-up }
"Each keyboard gesture has a set of modifiers and a key symbol. The set modifiers is denoted by an array which must either be " { $link f } ", or an order-preserving subsequence of the following:"
{ $code "{ S+ C+ A+ M+ }" }
{ $subsection S+ }
{ $subsection C+ }
{ $subsection A+ }
{ $subsection M+ }
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
  { $snippet "LEFT" }
  { $snippet "RIGHT" }
  { $snippet "DOWN" }
  { $snippet "UP" }
  { $snippet "PAGE_UP" }
  { $snippet "PAGE_DOWN" }
}
"The " { $link S+ } " modifier is only ever used with the above action keys; alphanumeric input input with the shift key is delivered without the " { $link S+ } " modifier set, instead the input itself is upper case. For example, the gesture corresponding to " { $snippet "s" } " with the Control and Shift keys pressed is presented as "
{ $code "T{ key-down f { C+ } \"S\" }" }
"The " { $snippet "RET" } ", " { $snippet "TAB" } " and " { $snippet "SPACE" } " keys are never delivered in their literal form (" { $snippet "\"\\n\"" } ", " { $snippet "\"\\t\"" } " or "  { $snippet "\" \"" } ")." ;

ARTICLE: "ui-user-input" "Free-form keyboard input"
"Whereas keyboard gestures are intended to be used for keyboard shortcuts, certain gadgets such as text fields need to accept free-form keyboard input. This can be done by implementing a generic word:"
{ $subsection user-input* } ;

ARTICLE: "mouse-gestures" "Mouse gestures"
"There are two types of mouse gestures indicating button clicks:"
{ $subsection button-down }
{ $subsection button-up }
"When a mouse button is pressed or released, two gestures are sent. The first gesture indicates the specific button number, and if this gesture is not handled, the second has a button number set to " { $link f } ":"
{ $code "T{ button-down f 1 }" "T{ button-down f f }" }
"Because tuple literals fill unspecified slots with " { $link f } ", the last gesture can be written as " { $snippet "T{ button-down }" } "."
$nl
"Gestures to indicate mouse motion, depending on whenever a button is held down or not:"
{ $subsection motion }
{ $subsection drag }
"Gestures to indicate that the mouse has crossed gadget boundaries:"
{ $subsection mouse-enter }
{ $subsection mouse-leave }
"A number of global variables are set after a mouse gesture is sent. These variables can be read to obtain additional information about the gesture."
{ $subsection hand-gadget }
{ $subsection hand-world }
{ $subsection hand-loc }
{ $subsection hand-buttons }
{ $subsection hand-clicked }
{ $subsection hand-click-loc }
{ $subsection hand-click# }
"There are some utility words for working with click locations:"
{ $subsection hand-rel }
{ $subsection hand-click-rel }
{ $subsection drag-loc }
"Mouse scroll wheel gesture:"
{ $subsection mouse-scroll }
"Global variable set when a mouse scroll wheel gesture is sent:"
{ $subsection scroll-direction } ;

ARTICLE: "action-gestures" "Action gestures"
"Action gestures exist to keep keyboard shortcuts for common clipboard operations consistent."
{ $subsection cut-action }
{ $subsection copy-action }
{ $subsection paste-action }
{ $subsection delete-action }
{ $subsection select-all-action }
"The following keyboard gestures, if not handled directly, send action gestures:"
{ $table
    { { $strong "Keyboard gesture" } { $strong "Action gesture" } }
    { { $snippet "T{ key-down f { C+ } \"x\" }" } { $snippet "T{ cut-action }" } }
    { { $snippet "T{ key-down f { C+ } \"c\" }" } { $snippet "T{ copy-action }" } }
    { { $snippet "T{ key-down f { C+ } \"v\" }" } { $snippet "T{ paste-action }" } }
    { { $snippet "T{ key-down f { C+ } \"a\" }" } { $snippet "T{ select-all }" } }
}
"Action gestures should be used in place of the above keyboard gestures if possible. For example, on Mac OS X, the standard " { $strong "Edit" } " menu items send action gestures." ;

ABOUT: "ui-gestures"
