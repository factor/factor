USING: inference.dataflow help.syntax help.markup ;

HELP: #return
{ $values { "label" "a word or " { $link f } } { "node" "a new " { $link node } } }
{ $description "Creates a node which returns from a nested label, or if " { $snippet "label" } " is " { $link f } ", the top-level word being compiled." } ;
