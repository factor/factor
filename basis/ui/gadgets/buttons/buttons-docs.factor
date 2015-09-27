USING: help.markup help.syntax ui.gadgets ui.gadgets.labels
ui.gadgets.toolbar ui.pens kernel models classes ;
IN: ui.gadgets.buttons

HELP: button
{ $class-description "A button is a " { $link gadget } " which responds to mouse clicks by invoking a quotation."
$nl
"A button's appearance can vary depending on the state of the mouse button if the " { $snippet "interior" } " or " { $snippet "boundary" } " slots are set to instances of " { $link button-pen } "."
$nl
"A button can be selected, which is distinct from being pressed. This state is held in the " { $snippet "selected?" } " slot, and is used by " { $link checkbox } " instances to render themselves when they're checked."
$nl
"A button can optionally display a message in the window's status bar whenever the mouse cursor hovers over the button. To enable this behavior, just set a string to the button's " { $snippet "tooltip" } " slot." } ;

HELP: <button>
{ $values { "label" gadget } { "quot" { $quotation ( button -- ) } } { "button" "a new " { $link button } } }
{ $description "Creates a new " { $link button } " which calls the quotation when clicked. The given gadget becomes the button's only child." } ;

HELP: <roll-button>
{ $values { "label" "a label specifier" } { "quot" { $quotation ( button -- ) } } { "button" button } }
{ $description "Creates a new " { $link button } " which is displayed with a solid border when it is under the mouse, informing the user that the gadget is clickable." } ;

HELP: <border-button>
{ $values { "label" "a label specifier" } { "quot" { $quotation ( button -- ) } } { "button" button } }
{ $description "Creates a new " { $link button } " with a border which is always visible. The button appearance changes in response to mouse gestures using a " { $link button-pen } "." } ;

HELP: <repeat-button>
{ $values { "label" object } { "quot" { $quotation ( button -- ) } } { "button" repeat-button } }
{ $description "Creates a new " { $link button } " derived from a " { $link <border-button> } " which calls the quotation every 100 milliseconds as long as the mouse button is held down." } ;

HELP: button-pen
{ $class-description "A class implementing the " { $link draw-boundary } " and " { $link draw-interior } " generic words by delegating to an object in one of four slots which depend on the state of the button being drawn:"
    { $list
        { { $snippet "plain"    } " - the button is inactive" }
        { { $snippet "rollover" } " - the button is under the mouse" }
        { { $snippet "pressed"  } " - the button is under the mouse and a mouse button is held down" }
        { { $snippet "selected" } " - the button is selected (see " { $link checkbox } ")" }
        { { $snippet "pressed-selected" } " - the button is selected and a mouse button is being held down (see " { $link checkbox } ")" }
    }
"The " { $link <roll-button> } " and " { $link <border-button> } " words create " { $link button } " instances with specific " { $link button-pen } "s." } ;

HELP: <command-button>
{ $values { "target" object } { "gesture" "a gesture" } { "command" "a command" } { "button" "a new " { $link button } } }
{ $description "Creates a " { $link <border-button> } " which invokes the command on " { $snippet "target" } " when clicked." } ;

ARTICLE: "ui.gadgets.buttons" "Button gadgets"
"The " { $vocab-link "ui.gadgets.buttons" } " vocabulary implements buttons. Buttons respond to mouse clicks by invoking a quotation."
{ $subsections button }
"There are many ways to create a new button:"
{ $subsections
    <button>
    <roll-button>
    <border-button>
    <repeat-button>
}
"Gadgets for invoking commands:"
{ $subsections
    <command-button>
    <toolbar>
}
"Button appearance can be customized:"
{ $subsections button-pen }
"Button constructors take " { $emphasis "label specifiers" } " as input. A label specifier is either a string, an array of strings, a gadget or " { $link f } "."
{ $see-also <command-button> "ui-commands" } ;

ABOUT: "ui.gadgets.buttons"
