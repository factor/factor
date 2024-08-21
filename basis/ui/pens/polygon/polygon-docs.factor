USING: colors help.markup help.syntax math math.matrices ui.pens ;
IN: ui.pens.polygon

HELP: polygon
{ $class-description "A class implementing the " { $link draw-boundary } " and " { $link draw-interior } " generic words to draw a solid outline or a solid filled polygon, respectively. Instances of " { $link polygon } " have two slots:"
    { $list
        { { $snippet "color" } " - a " { $link color } }
        { { $snippet "points" } " - a sequence of points" }
    }
} ;

HELP: <polygon>
{ $values { "color" color } { "points" "a sequence of points" } { "polygon" polygon } }
{ $description "Creates a new instance of " { $link polygon } "." } ;

HELP: polygon-circle
{ $values { "n" integer } { "diameter" real } { "vertices" matrix } }
{ $description "Approximates the vertices of a circle as a polygon with " { $snippet n } " amount of points." }
{ $code "USING: sequences math.vectors ui.gadgets.grids ui.gadgets.panes ui.theme ;
         9 <iota> 3 v+n [ 20 polygon-circle details-color swap <polygon-gadget> ] map
         1array <grid> gadget." } ;
