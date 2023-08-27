USING: cap help.markup help.syntax images opengl ui.gadgets.worlds ;
IN: cap

HELP: screenshot.
  { $values { "window" world } }
  { $description
    "Opens a window with a screenshot of the currently active window."
  } ;

HELP: screenshot
  { $values { "window" world } { "bitmap" image } }
  { $description
    "Creates a bitmap image of a UI window."
  }
  { $notes "If the current " { $link gl-scale-factor } " is " { $snippet "2.0" } ", then the " { $snippet "2x" } " slot in the resulting " { $link image } " will be " { $link t } "." } ;

