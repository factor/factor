USING: help.markup help.syntax math.rectangles ;
IN: math.rectangles.positioning

HELP: popup-rect
{ $values { "visible-rect" rect } { "popup-dim" "a pair of real numbers" } { "screen-dim" "a pair of real numbers" } { "rect" rect } }
{ $description "Calculates the position of a popup with a heuristic:"
  { $list
      { "The new rectangle must fit inside " { $snippet "screen-dim" } }
      { "The new rectangle must not obscure " { $snippet "visible-rect" } }
      { "The child must otherwise be as close as possible to the edges of " { $snippet "visible-rect" } }
  }
  "For example, when displaying a menu, " { $snippet "visible-rect" } " is a single point at the mouse location, and when displaying a completion popup, " { $snippet "visible-rect" } " contains the bounds of the text element being completed."
} ;
