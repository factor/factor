USING: help.syntax help.markup ui.gadgets kernel arrays
quotations classes.tuple ui.gadgets.grids parser ;
IN: ui.gadgets.frames

ARTICLE: "ui-frame-layout" "Frame layouts"
"Frames extend " { $link "ui-grid-layout" } " with the ability to give all remaining space to a distinguished filled cell."
$nl
"The filled cell's column/row pair is stored in the frame gadget's " { $slot "filled-cell" } " slot. If the actual dimensions of a frame exceed it preferred dimensions, then the fill slot is resized appropriately, together with its row and column."
$nl
"Because frames inherit from grids, grid layout words can be used to add and remove children."
{ $subsection frame }
"Creating empty frames:"
{ $subsection <frame> } ;

HELP: frame
{ $class-description "A frame is a gadget which lays out its children in a grid, and assigns all remaining space to a distinguished filled cell. The " { $slot "filled-cell" } " slot stores a pair with shape " { $snippet "{ col row }" } "."
$nl
"Frames are constructed by calling " { $link <frame> } " and since they inherit from " { $link grid } ", children can be managed with " { $link grid-add } " and " { $link grid-remove } "." } ;

HELP: <frame>
{ $values { "frame" frame } }
{ $description "Creates a new " { $link frame } " for laying out gadgets in a 3x3 grid." } ;

{ grid frame } related-words

ABOUT: "ui-frame-layout"
