USING: help.syntax help.markup ;

IN: math.ranges

ARTICLE: "ranges" "Ranges"

  "A " { $emphasis "range" } " is a virtual sequence with real elements "
  "ranging from " { $emphasis "a" } " to " { $emphasis "b" } " by " { $emphasis "step" } "."

  $nl

  "Creating ranges:"

  { $subsection <range> }
  { $subsection [a,b]   }
  { $subsection (a,b]   }
  { $subsection [a,b)   }
  { $subsection (a,b)   }
  { $subsection [0,b]   }
  { $subsection [1,b]   }
  { $subsection [0,b)   } ;