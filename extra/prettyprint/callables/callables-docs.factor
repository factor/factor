USING: help help.markup help.syntax kernel quotations ;
IN: prettyprint.callables

HELP: simplify-callable
{ $values { "quot" callable } { "quot'" callable } }
{ $description "Converts " { $snippet "quot" } " into an equivalent quotation by simplifying usages of " { $link dip } ", " { $link call } ", " { $link curry } ", and " { $link compose } " with literal parameters. This word is used when callable objects are prettyprinted." } ;
