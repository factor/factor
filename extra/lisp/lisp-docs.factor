IN: lisp
USING: help.markup help.syntax ;
HELP: <LISP
{ $description "parsing word which converts the lisp code between <LISP and LISP> into factor quotations and calls it" }
{ $see-also lisp-string>factor } ;

HELP: lisp-string>factor
{ $values { "str"  "a string of lisp code" } { "quot" "the quotation the lisp compiles into" } }
{ $description "Turns a string of lisp into a factor quotation" } ;

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