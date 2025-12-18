USING: help.markup help.syntax math models.range ui.gadgets
ui.gadgets.sliders.private ;
IN: ui.gadgets.sliders

HELP: elevator
{ $class-description "An elevator is the part of a " { $link slider } " between the up/down arrow buttons, where a " { $link thumb } " may be moved up and down." } ;

HELP: slider
{ $class-description "A slider is a control for graphically manipulating a " { $link "models.range" } "."
$nl
"Sliders are created by calling " { $link <slider> } "." } ;

HELP: find-slider
{ $values { "gadget" gadget } { "slider/f" { $maybe slider } } }
{ $description "Finds the first parent of " { $snippet "gadget" } " which is a " { $link slider } ". Outputs " { $link f } " if the gadget is not contained in a " { $link slider } "." } ;

HELP: thumb
{ $class-description "A thumb is the gadget contained in a " { $link slider } "'s " { $link elevator } " which indicates the current scroll position and can be dragged up and down with the mouse." } ;

HELP: slide-by
{ $values { "amount" integer } { "slider" slider } }
{ $description "Adds the amount (which may be positive or negative) to the slider's current position." } ;

HELP: slide-by-page
{ $values { "amount" integer } { "slider" slider } }
{ $description "Adds the amount multiplied by " { $link slider-page } " to the slider's current position." } ;

HELP: slide-by-line
{ $values { "amount" integer } { "slider" slider } }
{ $description "Adds the amount multiplied by the " { $snippet "line" } " slot to the slider's current position." } ;

HELP: <slider>
{ $values { "range" range } { "orientation" "an orientation specifier" } { "slider" "a new " { $link slider } } }
{ $description "Creates a new slider." } ;

ARTICLE: "ui.gadgets.sliders" "Slider gadgets"
"The " { $vocab-link "ui.gadgets.sliders" } " vocabulary implements slider gadgets. A slider allows the user to graphically manipulate a value by moving a thumb back and forth."
{ $subsections
    slider
    <slider>
}
"Changing slider values:"
{ $subsections
    slide-by
    slide-by-line
    slide-by-page
}
"Since sliders are controls the value can be get and set by via the " { $snippet "model" } " slot." ;

ABOUT: "ui.gadgets.sliders"
