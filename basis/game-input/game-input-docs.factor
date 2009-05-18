USING: help.markup help.syntax kernel ui.gestures quotations
sequences strings math ;
IN: game-input

ARTICLE: "game-input" "Game controller input"
"The " { $vocab-link "game-input" } " vocabulary provides cross-platform access to game controller devices such as joysticks and gamepads. It also provides an interface for polling raw keyboard and mouse input." $nl
"The game input interface must be initialized before being used:"
{ $subsection open-game-input }
{ $subsection close-game-input }
{ $subsection with-game-input }
"Once the game input interface is open, connected controller devices can be enumerated:"
{ $subsection get-controllers }
{ $subsection find-controller-products }
{ $subsection find-controller-instance }
"These " { $link controller } " objects can be queried of their identity:"
{ $subsection product-string }
{ $subsection product-id }
{ $subsection instance-id }
"A hook is provided for invoking the system calibration tool:"
{ $subsection calibrate-controller }
"The current state of a controller, the keyboard, and the mouse can be read:"
{ $subsection read-controller }
{ $subsection read-keyboard }
{ $subsection read-mouse }
{ $subsection controller-state }
{ $subsection keyboard-state }
{ $subsection mouse-state } ;

HELP: open-game-input
{ $description "Initializes the game input interface. An exception will be thrown if the initialization fails. Calls to open-game-input are reference counted; each call to open-game-input needs a corresponding call to close-game-input to close the game input interface." } ;

HELP: close-game-input
{ $description "Closes the game input interface, releasing any allocated resources. Once this word is called, any remaining " { $link controller } " objects are invalid." } ;

HELP: game-input-opened?
{ $values { "?" "a boolean" } }
{ $description "Returns true if the game input interface is open, false otherwise." } ;

HELP: with-game-input
{ $values { "quot" quotation } }
{ $description "Initializes the game input interface for the dynamic extent of " { $snippet "quotation" } "." } ;

{ open-game-input close-game-input with-game-input game-input-opened? } related-words

HELP: get-controllers
{ $values { "sequence" "A " { $link sequence } " of " { $link controller } "s" } }
{ $description "Returns a " { $link sequence } " of " { $link controller } " objects representing the currently connected game controllers. The order of the controller objects in the sequence is not significant or guaranteed to be stable between calls to " { $snippet "get-controllers" } "." } ;

HELP: find-controller-products
{ $values { "product-id" "A product ID as returned by " { $link product-id } } { "sequence" "A " { $link sequence } " of " { $link controller } "s" } }
{ $description "Returns a " { $link sequence } " of " { $link controller } " objects representing the currently connected game controllers with the given " { $link product-id } ". The order of the controller objects in the sequence is not significant or guaranteed to be stable between calls to " { $snippet "find-controller-products" } "." } ;

HELP: find-controller-instance
{ $values { "product-id" "A product ID as returned by " { $link product-id } } { "instance-id" "An instance ID as returned by " { $link instance-id } "." } { "controller/f" "A " { $link controller } " object, or " { $link f } } }
{ $description "Returns the " { $link controller } " instance identified by " { $snippet "product-id" } " and " { $snippet "instance-id" } ". If the identified device is not currently attached, " { $link f } " is returned." } ;

HELP: controller
{ $class-description "Objects of this class represent game controller devices such as joysticks and gamepads. They should be treated as opaque by client code." } ;

HELP: product-string
{ $values { "controller" controller } { "string" string } }
{ $description "Returns a human-readable string describing the game controller device represented by " { $snippet "controller" } ". This string is not necessarily unique to the product or instance; to uniquely identify the device, see " { $link product-id } " and " { $link instance-id } "." } ;

HELP: product-id
{ $values { "controller" controller } { "id" "A unique identifier" } }
{ $description "Returns an identifier uniquely representing the kind of game controller device represented by " { $snippet "controller" } ". This identifier will be the same for devices of the same make and manufacturer. The type of the identifier value is platform-specific, but equivalent " { $snippet "product-id" } "s are guaranteed to be testable with the " { $link = } " word. The identifier can be used to find devices of the same kind with the " { $link find-controller-products } " word." } ;

HELP: instance-id
{ $values { "controller" controller } { "id" "A unique identifier" } }
{ $description "Returns an identifier uniquely representing the game controller device represented by " { $snippet "controller" } ". This identifier paired with the device's " { $link product-id } " provides a unique identifier for a particular device that persists between reboots (but not necessarily between computers). This unique identifier can be used to find the same device again with the " { $snippet "find-controller-instance" } " word. Depending on the platform, the instance-id may change if the device is plugged into a different port. The type of the identifier value is platform-specific, but equivalent " { $snippet "instance-id" } "s are guaranteed to be testable with the " { $link = } " word." } ;

{ product-string product-id instance-id find-controller-products find-controller-instance } related-words

HELP: calibrate-controller
{ $values { "controller" controller } }
{ $description "Invokes the operating system's calibration tool for " { $snippet "controller" } ". If the operating system does not have a calibration tool, this word does nothing." } ;

HELP: read-controller
{ $values { "controller" controller } { "controller-state" controller-state } }
{ $description "Reads the current state of " { $snippet "controller" } ". See the documentation for the " { $link controller-state } " class for details of the returned value's format. If the device is no longer available, " { $link f } " is returned." }
{ $warning "For efficiency, the implementation may reuse the returned " { $snippet "controller-state" } " object next time " { $snippet "read-controller" } " is called on the same controller. You should " { $link clone } " any values from the returned tuple you need to preserve." } ;

{ controller-state controller read-controller } related-words

HELP: read-keyboard
{ $values { "keyboard-state" keyboard-state } }
{ $description "Reads the current raw state of the keyboard. See the documentation for the " { $link keyboard-state } " class for details on the returned value's format." }
{ $warning "For efficiency, the implementation may reuse the returned " { $snippet "keyboard-state" } " object next time " { $snippet "read-keyboard" } " is called. You should " { $link clone } " any values from the returned tuple you need to preserve."
$nl "The keyboard state returned by this word is unprocessed by any keymaps, modifier keys, key repeat settings, or other operating environment postprocessing. Because of this, " { $snippet "read-keyboard" } " should not be used for text entry purposes. The Factor UI's standard gesture mechanism should be used in cases where the logical meaning of keypresses is needed; see " { $link "keyboard-gestures" } "." } ;

HELP: read-mouse
{ $values { "mouse-state" mouse-state } }
{ $description "Reads the current mouse state relative to either when the game input interface was opened with " { $link open-game-input } " or when the mouse state was reset with " { $link reset-mouse } "." }
{ $warning "For efficiency, the implementation may reuse the returned " { $snippet "mouse-state" } " object for future " { $snippet "read-mouse" } " or " { $snippet "reset-mouse" } " calls. You should " { $link clone } " the " { $snippet "mouse-state" } " object if you need to preserve it." } ;

HELP: reset-mouse
{ $description "Resets the mouse state. Future " { $link read-mouse } " values will be relative to the time this word is called." } ;

HELP: controller-state
{ $class-description "The " { $link read-controller } " word returns objects of this class. " { $snippet "controller-state" } " objects have the following slots:"
{ $list
    { { $snippet "x" } " contains the position of the device's X axis." }
    { { $snippet "y" } " contains the position of the device's Y axis." }
    { { $snippet "z" } " contains the position of the device's Z axis, if any." }
    { { $snippet "rx" } " contains the rotational position of the device's X axis, if available." }
    { { $snippet "ry" } " contains the rotational position of the device's Y axis, if available." }
    { { $snippet "rz" } " contains the rotational position of the device's Z axis, if available." }
    { { $snippet "slider" } " contains the position of the device's throttle slider, if any." }
    { { $snippet "pov" } " contains the state of the device's POV hat, if any." }
    { { $snippet "buttons" } " contains a sequence of values indicating the state of every button on the device." }
}
"The values are formatted as follows:"
{ $list
    { "For the axis slots (" { $snippet "x" } ", " { $snippet "y" } ", " { $snippet "z" } ", " { $snippet "rx" } ", " { $snippet "ry" } ", " { $snippet "rz" } "), a " { $link float } " value between -1.0 and 1.0 is returned." }
    { "For the " { $snippet "slider" } " slot, a value between 0.0 and 1.0 is returned." }
    { "For the " { $snippet "pov" } " slot, one of the following symbols is returned:" { $list
        { { $link pov-neutral } }
        { { $link pov-up } }
        { { $link pov-up-right } }
        { { $link pov-right } }
        { { $link pov-down-right } }
        { { $link pov-down } }
        { { $link pov-down-left } }
        { { $link pov-left } }
        { { $link pov-up-left } }
    } }
    { "For each element of the " { $snippet "buttons" } " array, " { $link f } " indicates that the corresponding button is released. If the button is pressed, a value between 0.0 and 1.0 is returned indicating the pressure on the button (or simply 1.0 if the device's buttons are on/off only)." }
    { "A value of " { $link f } " in any slot (besides the elements of " { $snippet "buttons" } ") indicates that the corresponding element is not present on the device." } } } ;

HELP: keyboard-state
{ $class-description "The " { $link read-keyboard } " word returns objects of this class. The " { $snippet "keys" } " slot of a " { $snippet "keyboard-state" } " object contains a " { $link sequence } " of 256 members representing the state of the keys on the keyboard. Each element is a boolean value indicating whether the corresponding key is pressed. The sequence is indexed by scancode as defined under usage page 7 of the USB HID standard. Named scancode constants are provided in the " { $vocab-link "game-input.scancodes" } " vocabulary." }
{ $warning "The scancodes used to index " { $snippet "keyboard-state" } " objects correspond to physical key positions on the keyboard--they are unaffected by keymaps, modifier keys, or other operating environment postprocessing. The face value of the constants in " { $vocab-link "game-input.scancodes" } " do not necessarily correspond to what the user expects the key to type. Because of this, " { $link read-keyboard } " should not be used for text entry purposes. The Factor UI's standard gesture mechanism should be used in cases where the logical meaning of keypresses is needed; see " { $link "keyboard-gestures" } "." } ;

HELP: mouse-state
{ $class-description "The " { $link read-mouse } " word returns objects of this class. " { $snippet "mouse-state" } " objects have the following slots:"
{ $list
    { { $snippet "dx" } " contains the mouse's X axis movement." }
    { { $snippet "dy" } " contains the mouse's Y axis movement." }
    { { $snippet "scroll-dx" } " contains the scroller's X axis movement." }
    { { $snippet "scroll-dy" } " contains the scroller's Y axis movement." }
    { { $snippet "buttons" } " contains a sequence of boolean values indicate the state of the mouse's buttons." }
}
"Mouse movement is recorded relative to when the game input interface was opened with " { $link open-game-input } " or the mouse state is reset with " { $link reset-mouse } "."
} ;


{ keyboard-state read-keyboard } related-words

ABOUT: "game-input"
