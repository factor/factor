USING: help.syntax help.markup ;

IN: math.ranges

ARTICLE: "ranges" "Ranges"

  "A " { $emphasis "range" } " is a virtual sequence with elements "
  "ranging from a to b by step."

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