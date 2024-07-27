IN: ui.pens.solid
USING: help.markup help.syntax ui.pens colors ;

HELP: solid
{ $class-description "A class implementing the " { $link draw-boundary } " and "
{ $link draw-interior } " generic words to draw a solid outline or a solid fill"
", respectively. The " { $snippet "color" } " slot stores an instance of "
{ $link color } "." }
{ $notes "See " { $link "colors" } "." } ;

HELP: <solid>
{ $values
    { "color" color }
    { "solid" solid }
}
{ $description "Creates a solid pen with the given color object. This"
" represents a solid outline or a solid fill." } ;
