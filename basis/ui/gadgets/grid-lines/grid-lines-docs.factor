USING: ui.gadgets help.markup help.syntax ui.gadgets.grids
ui.render ;
IN: ui.gadgets.grid-lines

HELP: grid-lines
{ $class-description "A class implementing the " { $link draw-boundary } " generic word to draw lines between the cells of a " { $link grid } ". The color of the lines is a color specifier stored in the " { $link grid-lines-color } " slot." } ;
