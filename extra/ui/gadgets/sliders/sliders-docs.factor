USING: help.markup help.syntax ui.gadgets models ;
IN: ui.gadgets.sliders

HELP: elevator
{ $class-description "An elevator is the part of a " { $link slider } " between the up/down arrow buttons, where a " { $link thumb } " may be moved up and down." } ;

HELP: find-elevator
{ $values { "gadget" gadget } { "elevator/f" "an " { $link elevator } " or " { $link f } } }
{ $description "Finds the first parent of " { $snippet "gadget" } " which is an " { $link elevator } ". Outputs " { $link f } " if the gadget is not contained in an " { $link elevator } "." } ;

HELP: slider
{ $class-description "A slider is a " { $link control } " for graphically manipulating a " { $link "models-range" } "."
$nl
"Sliders are created by calling " { $link <x-slider> } " or " { $link <y-slider> } "." } ;

HELP: find-slider
{ $values { "gadget" gadget } { "slider/f" "a " { $link slider } " or " { $link f } } }
{ $description "Finds the first parent of " { $snippet "gadget" } " which is a " { $link slider } ". Outputs " { $link f } " if the gadget is not contained in a " { $link slider } "." } ;

HELP: thumb
{ $class-description "A thumb is the gadget contained in a " { $link slider } "'s " { $link elevator } " which indicates the current scroll position and can be dragged up and down with the mouse." } ;

HELP: slide-by
{ $values { "amount" "an integer" } { "slider" slider } }
{ $description "Adds the amount (which may be positive or negative) to the slider's current position." } ;

HELP: slide-by-page
{ $values { "amount" "an integer" } { "slider" slider } }
{ $description "Adds the amount multiplied by " { $link slider-page } " to the slider's current position." } ;

HELP: slide-by-line
{ $values { "amount" "an integer" } { "slider" slider } }
{ $description "Adds the amount multiplied by " { $link slider-line } " to the slider's current position." } ;

HELP: <slider>
{ $values { "range" range } { "orientation" "an orientation specifier" } { "slider" "a new " { $link slider } } }
{ $description "Internal word for constructing sliders." }
{ $notes "This does not build a complete slider, and user code should call " { $link <x-slider> } " or " { $link <y-slider> } " instead." } ;

HELP: <x-slider>
{ $values { "range" range } { "slider" slider } }
{ $description "Creates a new horizontal " { $link slider } "." } ;

HELP: <y-slider>
{ $values { "range" range } { "slider" slider } }
{ $description "Creates a new vertical " { $link slider } "." } ;

{ <x-slider> <y-slider> } related-words

ARTICLE: "ui.gadgets.sliders" "Slider gadgets"
"A slider allows the user to graphically manipulate a value by moving a thumb back and forth."
{ $subsection slider }
{ $subsection <x-slider> }
{ $subsection <y-slider> }
"Changing slider values:"
{ $subsection slide-by }
{ $subsection slide-by-line }
{ $subsection slide-by-page }
"Since sliders are controls the value can be get and set by calling " { $link control-model } "." ;

ABOUT: "ui.gadgets.sliders"
