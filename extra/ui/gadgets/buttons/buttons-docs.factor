USING: ui.gadgets.buttons help.markup help.syntax ui.gadgets
ui.gadgets.labels ui.gadgets.menus ui.render kernel models
classes ;

HELP: button
{ $class-description "A button is a " { $link gadget } " which responds to mouse clicks by invoking a quotation."
$nl
"A button's appearance can vary depending on the state of the mouse button if the " { $link gadget-interior } " or " { $link gadget-boundary } " slots are set to instances of " { $link button-paint } "."
$nl
"A button can be selected, which is distinct from being pressed. This state is held in the " { $link button-selected? } " slot, and is used by the " { $link <radio-box> } " word to construct a row of buttons for choosing among several alternatives." } ;

HELP: >label
{ $values { "obj" "a label specifier" } { "gadget" "a new " { $link gadget } } }
{ $description "Convert the object into a gadget suitable for use as the label of a button. If " { $snippet "obj" } " is already a gadget, does nothing. Otherwise creates a " { $link label } " gadget if it is a string and an empty gadget if " { $snippet "obj" } " is " { $link f } "." } ;

HELP: <button>
{ $values { "gadget" gadget } { "quot" "a quotation with stack effect " { $snippet "( button -- )" } } { "button" "a new " { $link button } } }
{ $description "Creates a new " { $link button } " which calls the quotation when clicked. The given gadget becomes the button's delegate." } ;

HELP: <roll-button>
{ $values { "label" "a label specifier" } { "quot" "a quotation with stack effect " { $snippet "( button -- )" } } { "button" button } }
{ $description "Creates a new " { $link button } " which is displayed with a solid border when it is under the mouse, informing the user that the gadget is clickable." } ;

HELP: <bevel-button>
{ $values { "label" "a label specifier" } { "quot" "a quotation with stack effect " { $snippet "( button -- )" } } { "button" button } }
{ $description "Creates a new " { $link button } " with a shaded border which is always visible. The button appearance changes in response to mouse gestures using a " { $link button-paint } "." } ;

HELP: <repeat-button>
{ $values { "label" object } { "quot" "a quotation with stack effect " { $snippet "( button -- )" } } { "button" repeat-button } }
{ $description "Creates a new " { $link button } " derived from a " { $link <bevel-button> } " which calls the quotation every 100 milliseconds as long as the mouse button is held down." } ;

HELP: button-paint
{ $class-description "A class implementing the " { $link draw-boundary } " and " { $link draw-interior } " gneeric words by delegating to an object in one of four slots which depend on the state of the button being drawn:"
    { $list
        { { $link button-paint-plain } " - the button is inactive" }
        { { $link button-paint-rollover } " - the button is under the mouse" }
        { { $link button-paint-pressed } " - the button is under the mouse and a mouse button is held down" }
        { { $link button-paint-selected } " - the button is selected (see " { $link <radio-box> }  }
    }
"The " { $link <roll-button> } " and " { $link <bevel-button> } " words create " { $link button } " instances with specific " { $link button-paint } "." } ;

HELP: <radio-control>
{ $values { "model" model } { "value" object } { "label" "a label specifier" } { "gadget" gadget } }
{ $description
    "Creates a " { $link <bevel-button> } " which sets the model's value to " { $snippet "value" } " when pressed. After being pressed, the button becomes selected until the value of the model changes again."
}
{ $notes "Typically a row of radio controls should be built together using " { $link <radio-box> } "." } ;

HELP: <radio-box>
{ $values { "model" model } { "assoc" "an association list mapping labels to objects" } { "gadget" gadget } }
{ $description "Creates a row of labelled " { $link <radio-control> } " gadgets which change the value of the model." } ;

HELP: <command-button>
{ $values { "target" object } { "gesture" "a gesture" } { "command" "a command" } { "button" "a new " { $link button } } }
{ $description "Creates a " { $link <bevel-button> } " which invokes the command on " { $snippet "target" } " when clicked." } ;

HELP: <toolbar>
{ $values { "target" object } { "toolbar" gadget } }
{ $description "Creates a row of " { $link <command-button> } " gadgets invoking commands on " { $snippet "target" } ". The commands are taken from the " { $snippet "\"toolbar\"" } " command group of each class in " { $snippet "classes" } "." } ;

HELP: <commands-menu>
{ $values { "hook" "a quotation with stack effect " { $snippet "( button -- )" } } { "target" object } { "commands" "a sequence of commands" } { "gadget" "a new " { $link gadget } } }
{ $description "Creates a popup menu of commands which are to be invoked on " { $snippet "target" } ". The " { $snippet "hook" } " quotation is run before a command is invoked." } ;

ARTICLE: "ui.gadgets.buttons" "Button gadgets"
"Buttons respond to mouse clicks by invoking a quotation."
{ $subsection button }
"There are many ways to create a new button:"
{ $subsection <button> }
{ $subsection <roll-button> }
{ $subsection <bevel-button> }
{ $subsection <repeat-button> }
"Gadgets for invoking commands:"
{ $subsection <command-button> }
{ $subsection <toolbar> }
"A radio box is a row of buttons for choosing amongst several distinct possibilities:"
{ $subsection <radio-box> }
"Button appearance can be customized:"
{ $subsection button-paint }
"Button constructors take " { $emphasis "label specifiers" } " as input. A label specifier is either a string, an array of strings, a gadget or " { $link f } "."
$nl
"A generic word used to convert label specifiers to gadgets:"
{ $subsection >label }
{ $see-also <command-button> "ui-commands" } ;
