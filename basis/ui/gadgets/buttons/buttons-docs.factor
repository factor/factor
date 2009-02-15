USING: help.markup help.syntax ui.gadgets ui.gadgets.labels
ui.pens kernel models classes ;
IN: ui.gadgets.buttons

HELP: button
{ $class-description "A button is a " { $link gadget } " which responds to mouse clicks by invoking a quotation."
$nl
"A button's appearance can vary depending on the state of the mouse button if the " { $snippet "interior" } " or " { $snippet "boundary" } " slots are set to instances of " { $link button-pen } "."
$nl
"A button can be selected, which is distinct from being pressed. This state is held in the " { $snippet "selected?" } " slot, and is used by the " { $link <toggle-buttons> } " word to construct a row of buttons for choosing among several alternatives." } ;

HELP: <button>
{ $values { "label" gadget } { "quot" { $quotation "( button -- )" } } { "button" "a new " { $link button } } }
{ $description "Creates a new " { $link button } " which calls the quotation when clicked. The given gadget becomes the button's only child." } ;

HELP: <roll-button>
{ $values { "label" "a label specifier" } { "quot" { $quotation "( button -- )" } } { "button" button } }
{ $description "Creates a new " { $link button } " which is displayed with a solid border when it is under the mouse, informing the user that the gadget is clickable." } ;

HELP: <bevel-button>
{ $values { "label" "a label specifier" } { "quot" { $quotation "( button -- )" } } { "button" button } }
{ $description "Creates a new " { $link button } " with a shaded border which is always visible. The button appearance changes in response to mouse gestures using a " { $link button-pen } "." } ;

HELP: <repeat-button>
{ $values { "label" object } { "quot" { $quotation "( button -- )" } } { "button" repeat-button } }
{ $description "Creates a new " { $link button } " derived from a " { $link <bevel-button> } " which calls the quotation every 100 milliseconds as long as the mouse button is held down." } ;

HELP: button-pen
{ $class-description "A class implementing the " { $link draw-boundary } " and " { $link draw-interior } " gneeric words by delegating to an object in one of four slots which depend on the state of the button being drawn:"
    { $list
        { { $snippet "plain"    } " - the button is inactive" }
        { { $snippet "rollover" } " - the button is under the mouse" }
        { { $snippet "pressed"  } " - the button is under the mouse and a mouse button is held down" }
        { { $snippet "selected" } " - the button is selected (see " { $link <toggle-buttons> }  }
    }
"The " { $link <roll-button> } " and " { $link <bevel-button> } " words create " { $link button } " instances with specific " { $link button-pen } "." } ;

HELP: <toggle-button>
{ $values { "model" model } { "value" object } { "label" "a label specifier" } { "gadget" gadget } }
{ $description
    "Creates a " { $link <bevel-button> } " which sets the model's value to " { $snippet "value" } " when pressed. After being pressed, the button becomes selected until the value of the model changes again."
}
{ $notes "Typically a row of radio controls should be built together using " { $link <toggle-buttons> } "." } ;

HELP: <toggle-buttons>
{ $values { "model" model } { "assoc" "an association list mapping labels to objects" } { "gadget" gadget } }
{ $description "Creates a row of labeled " { $link <toggle-button> } " gadgets which change the value of the model." } ;

HELP: <command-button>
{ $values { "target" object } { "gesture" "a gesture" } { "command" "a command" } { "button" "a new " { $link button } } }
{ $description "Creates a " { $link <bevel-button> } " which invokes the command on " { $snippet "target" } " when clicked." } ;

HELP: <toolbar>
{ $values { "target" object } { "toolbar" gadget } }
{ $description "Creates a row of " { $link <command-button> } " gadgets invoking commands on " { $snippet "target" } ". The commands are taken from the " { $snippet "\"toolbar\"" } " command group of each class in " { $snippet "classes" } "." } ;

ARTICLE: "ui.gadgets.buttons" "Button gadgets"
"The " { $vocab-link "ui.gadgets.buttons" } " vocabulary implements buttons. Buttons respond to mouse clicks by invoking a quotation."
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
{ $subsection <toggle-buttons> }
"Button appearance can be customized:"
{ $subsection button-pen }
"Button constructors take " { $emphasis "label specifiers" } " as input. A label specifier is either a string, an array of strings, a gadget or " { $link f } "."
{ $see-also <command-button> "ui-commands" } ;

ABOUT: "ui.gadgets.buttons"
