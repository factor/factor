IN: lisp
USING: help.markup help.syntax ;

ARTICLE: "lisp" "Lisp in Factor"
"This is a simple implementation of a Lisp dialect, which somewhat resembles Scheme." $nl
"It works in two main stages: "
{ $list
  { "Parse (via "  { $vocab-link "lisp.parser" } " the Lisp code into a "
    { $snippet "s-exp"  } " tuple." }
  { "Transform the " { $snippet "s-exp" } " into a Factor quotation, via " { $link convert-form } }
}

{ $subsection "lisp.parser" } ;

ABOUT: "lisp"