USING: colors help.markup help.syntax ui.pens ;
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
