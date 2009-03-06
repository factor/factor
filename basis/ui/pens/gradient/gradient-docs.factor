IN: ui.pens.gradient
USING: help.markup help.syntax ui.pens colors ;

HELP: gradient
{ $class-description "A class implementing the " { $link draw-interior } " generic word to draw a smoothly shaded transition between colors. The " { $snippet "colors" } " slot stores a sequence of " { $link color } " instances, and the gradient is drawn in the direction given by the " { $snippet "orientation" } " slot of the gadget." }
{ $notes "See " { $link "colors" } "." } ;
