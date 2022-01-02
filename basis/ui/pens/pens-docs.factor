IN: ui.pens
USING: help.markup help.syntax kernel ui.gadgets ;

HELP: draw-interior
{ $values { "gadget" gadget } { "pen" object } }
{ $contract "Draws the interior of a gadget by making OpenGL calls. The " { $snippet "interior" } " slot may be set to objects implementing this generic word." } ;

HELP: draw-boundary
{ $values { "gadget" gadget } { "pen" object } }
{ $contract "Draws the boundary of a gadget by making OpenGL calls. The " { $snippet "boundary" } " slot may be set to objects implementing this generic word." } ;

ARTICLE: "ui-pen-protocol" "UI pen protocol"
"The " { $snippet "interior" } " and " { $snippet "boundary" } " slots of a gadget facilitate easy factoring and sharing of drawing logic. Objects stored in these slots must implement the pen protocol:"
{ $subsections
    draw-interior
    draw-boundary
}
"The default value of these slots is the " { $link f } " singleton, which implements the above protocol by doing nothing."
$nl
"Some other pre-defined implementations:"
{ $vocab-subsections
    { "Gradient pens" "ui.pens.gradient" }
    { "Image pens" "ui.pens.image" }
    { "Polygon pens" "ui.pens.polygon" }
    { "Solid pens" "ui.pens.solid" }
    { "Tile pens" "ui.pens.tile" }
}
"Custom implementations must follow the guidelines set forth in " { $link "ui-paint-custom" } "." ;
