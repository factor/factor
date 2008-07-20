USING: help.markup help.syntax kernel ui.gestures quotations
sequences strings math ;
IN: game-input

ARTICLE: "game-input" "Game controller input"
"The " { $vocab-link "game-input" } " vocabulary provides cross-platform access to game controller devices such as joysticks and gamepads. It also provides an interface to for polling raw keyboard input." $nl
"The game input interface must be initialized before being used:"
{ $subsection open-game-input }
{ $subsection close-game-input }
{ $subsection with-game-input }
"Once the game input interface is open, connected controller devices can be enumerated:"
{ $subsection get-controllers }
"These " { $link controller } " objects can be queried of their identity:"
{ $subsection manufacturer }
{ $subsection product }
{ $subsection vendor-id }
{ $subsection product-id }
{ $subsection location-id }
"A hook is provided for invoking the system calibration tool:"
{ $subsection calibrate-controller }
"The current state of a controller or the keyboard can be read:"
{ $subsection read-controller }
{ $subsection read-keyboard }
{ $subsection controller-state }
{ $subsection keyboard-state } ;

HELP: open-game-input
{ $description "Initializes the game input interface. An exception will be thrown if the initialization fails." } ;

HELP: close-game-input
{ $description "Closes the game input interface, releasing any allocated resources." } ;

HELP: with-game-input
{ $values { "quot" quotation } }
{ $description "Initializes the game input interface for the dynamic extent of " { $snippet "quotation" } "." } ;

{ open-game-input close-game-input with-game-input } related-words

HELP: get-controllers
{ $values { "sequence" "A " { $link sequence } " of " { $link controller } "s" } }
{ $description "Returns a " { $link sequence } " of " { $link controller } " objects representing the currently connected game controllers." } ;

HELP: controller
{ $class-description "Objects of this class represent game controller devices such as joysticks and gamepads. They should be treated as opaque by client code." } ;

HELP: manufacturer
{ $values { "controller" controller } { "string" string } }
{ $description "Returns a human-readable string describing the manufacturer of the game controller device represented by " { $snippet "controller" } "." } ;

HELP: product
{ $values { "controller" controller } { "string" string } }
{ $description "Returns a human-readable string describing the game controller device represented by " { $snippet "controller" } "." } ;

HELP: vendor-id
{ $values { "controller" controller } { "integer" integer } }
{ $description "Returns an identifier uniquely representing the manufacturer of the game controller device represented by " { $snippet "controller" } "." } ;

HELP: product-id
{ $values { "controller" controller } { "integer" integer } }
{ $description "Returns an identifier uniquely representing the kind of game controller device represented by " { $snippet "controller" } "." } ;

HELP: location-id
{ $values { "controller" controller } { "integer" integer } }
{ $description "Returns an identifier uniquely representing the game controller device represented by " { $snippet "controller" } "'s location in the system." } ;

{ manufacturer product-id vendor-id product-id location-id } related-words

HELP: calibrate-controller
{ $values { "controller" controller } }
{ $description "Invokes the operating system's calibration tool for " { $snippet "controller" } ". If the operating system does not have a calibration tool, does nothing." } ;

HELP: read-controller
{ $values { "controller" controller } { "controller-state" controller-state } }
{ $description "Reads the current state of " { $snippet "controller" } ". See the documentation for the " { $link controller-state } " class for details of the returned value's format." } ;

{ controller-state controller read-controller } related-words

HELP: read-keyboard
{ $values { "keyboard-state" keyboard-state } }
{ $description "Reads the current raw state of the keyboard. See the documentation for the " { $link keyboard-state } " class for details on the returned value's format." }
{ $warning "The keyboard state returned by this word is unprocessed by any keymaps, key repeat settings, or other operating environment postprocessing. Because of this, " { $snippet "read-keyboard" } " should not be used for text entry purposes. The Factor UI's standard gesture mechanism should be used in cases where the logical meaning of keypresses is necessary; see " { $link "keyboard-gestures" } "." } ;

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
    { "A value of " { $link f } " in any slot (besides the elements of " { $snippet "buttons" } ") indicates that the corresponding axis is not present on the device." } } } ;

HELP: keyboard-state
{ $class-description "The " { $link read-keyboard } " word returns objects of this class. The " { $snippet "keys" } " slot of a " { $snippet "keyboard-state" } " object contains a " { $link sequence } " of 256 members representing the state of the keys on the keyboard. Each element is a boolean value indicating whether the corresponding key is pressed. The sequence is indexed by scancode as defined under usage page 7 of the USB HID standard. Named scancode constants are provided in the " { $vocab-link "game-input.scancodes" } " vocabulary." }
{ $warning "The scancodes used to index " { $snippet "keyboard-state" } " objects correspond to physical key positions on the keyboard--they are unaffected by keymaps or other operating environment postprocessing. The face value of the constants in " { $vocab-link "game-input.scancodes" } " do not necessarily correspond to what the user expects the key to type. Because of this, " { $link read-keyboard } " should not be used for text entry purposes. The Factor UI's standard gesture mechanism should be used in cases where the logical meaning of keypresses is necessary; see " { $link "keyboard-gestures" } "." } ;

{ keyboard-state read-keyboard } related-words
