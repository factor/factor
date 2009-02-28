USING: help.syntax help.markup ui.gadgets kernel arrays math help sequences
quotations classes.tuple ui.gadgets.grids ;
IN: ui.gadgets.frames

ARTICLE: "ui-frame-layout" "Frame layouts"
"Frames resemble " { $link "ui-grid-layout" } " except the size of grid is fixed at 3x3, and the center gadget fills up any available space. Because frames inherit from grids, grid layout words can be used to add and remove children."
{ $subsection frame }
"Creating empty frames:"
{ $subsection <frame> }
"A set of mnemonic words for the positions on a frame's 3x3 grid; these words push values which may be passed to " { $link grid-add } ":"
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
    { $description "Symbolic constant for a common input to " { $link grid-add } "." } print-element ;

{ @center @left @right @top @bottom @top-left @top-right @bottom-left @bottom-right }
[
    [
        {
            { $values { "i" integer } { "j" integer } }
            { $ui-frame-constant }
        }
    ] dip set-word-help
] each

HELP: frame
{ $class-description "A frame is a gadget which lays out its children in a 3x3 grid. If the frame is enlarged past its preferred size, the center gadget fills up available room."
$nl
"Frames are constructed by calling " { $link <frame> } " and since they inherit from " { $link grid } ", children can be managed with " { $link grid-add } " and " { $link grid-remove } "." } ;

HELP: <frame>
{ $values { "frame" frame } }
{ $description "Creates a new " { $link frame } " for laying out gadgets in a 3x3 grid." } ;

{ grid frame } related-words

ABOUT: "ui-frame-layout"
