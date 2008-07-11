USING: help.syntax help.markup ui.gadgets kernel arrays
quotations classes.tuple ui.gadgets.grids ;
IN: ui.gadgets.frames

ARTICLE: "ui-frame-layout" "Frame layouts"
"Frames resemble " { $link "ui-grid-layout" } " except the size of grid is fixed at 3x3, and the center gadget fills up any available space. Because frames delegate to grids, grid layout words can be used to add and remove children."
{ $subsection frame }
"Creating empty frames:"
{ $subsection <frame> }
"Creating new frames using a combinator:"
{ $subsection make-frame }
{ $subsection frame, }
"A set of mnemonic words for the positions on a frame's 3x3 grid; these words push values which may be passed to " { $link grid-add } " or " { $link frame, } ":"
{ $subsection @center }
{ $subsection @left }
{ $subsection @right }
{ $subsection @top }
{ $subsection @bottom }
{ $subsection @top-left }
{ $subsection @top-right }
{ $subsection @bottom-left }
{ $subsection @bottom-right } ;

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

{ <frame> make-frame } related-words

HELP: make-frame
{ $values { "quot" quotation } { "frame" frame } }
{ $description "Creates a new frame. The quotation can add children by calling the " { $link frame, } " word." } ;

HELP: frame,
{ $values { "gadget" gadget } { "i" "non-negative integer" } { "j" "non-negative integer" } }
{ $description "Adds a child gadget at the specified location. This word can only be called inside the quotation passed to " { $link make-frame } "." } ;

{ grid frame } related-words

ABOUT: "ui-frame-layout"
