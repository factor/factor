IN: lisp.parser
USING: help.markup help.syntax ;

ARTICLE: "lisp.parser" "Parsing strings of Lisp"
"This vocab uses " { $vocab-link "peg.ebnf" } " to turn strings of Lisp into " { $snippet "s-exp" } "s, which are then used by"
{ $vocab-link "lisp" } " to produce Factor quotations." ;