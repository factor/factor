USING: help.syntax ui.gadgets kernel arrays quotations tuples
ui.gadgets.grids ui.gadgets.frames ;
IN: help.markup

: $ui-frame-constant ( element -- )
    drop
    { $description "Symbolic constant for a common input to " { $link grid-add } " and " { $link frame, } "." } print-element ;

HELP: @center $ui-frame-constant ;
HELP: @left $ui-frame-constant ;
HELP: @right $ui-frame-constant ;
HELP: @top $ui-frame-constant ;
HELP: @bottom $ui-frame-constant ;
HELP: @top-left $ui-frame-constant ;
HELP: @top-right $ui-frame-constant ;
HELP: @bottom-left $ui-frame-constant ;
HELP: @bottom-right $ui-frame-constant ;

HELP: frame
{ $class-description "A frame is a gadget which lays out its children in a 3x3 grid. If the frame is enlarged past its preferred size, the center gadget fills up available room."
$nl
"Frames are constructed by calling " { $link <frame> } " and since they delegate to " { $link grid } " instances, children can be managed with " { $link grid-add } " and " { $link grid-remove } "." } ;

HELP: <frame>
{ $values { "frame" frame } }
{ $description "Creates a new " { $link frame } " for laying out gadgets in a 3x3 grid." } ;

{ <frame> make-frame build-frame } related-words

HELP: make-frame
{ $values { "quot" quotation } { "frame" frame } }
{ $description "Creates a new frame. The quotation can add children by calling the " { $link frame, } " word." } ;

HELP: build-frame
{ $values { "tuple" tuple } { "quot" quotation } }
{ $description "Creates a new frame and sets " { $snippet "tuple" } "'s delegate to the new frame. The quotation can add children by calling the " { $link frame, } " word, and access the frame by calling " { $link g } " or " { $link g-> } "." } ;

HELP: frame,
{ $values { "gadget" gadget } { "i" "non-negative integer" } { "j" "non-negative integer" } }
{ $description "Adds a child gadget at the specified location. This word can only be called inside the quotation passed to " { $link make-frame } " or " { $link build-frame } "." } ;

{ grid frame } related-words
