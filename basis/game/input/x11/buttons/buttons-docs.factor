USING: help.markup help.syntax math sequences ;
IN: game.input.x11.buttons

HELP: button-mask>buttons
{ $values { "mask" integer } { "buttons" sequence } }
{ $description "Converts an X11 pointer state mask to five booleans in X11 button order. Keyboard modifier bits are ignored." } ;
