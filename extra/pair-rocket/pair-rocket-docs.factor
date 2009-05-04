! (c)2009 Joe Groff bsd license
USING: help.markup help.syntax multiline ;
IN: pair-rocket

HELP: =>
{ $syntax "a => b" }
{ $description "Constructs a two-element array from the objects immediately before and after the " { $snippet "=>" } ". This syntax can be used inside sequence and assoc literals." }
{ $examples
{ $unchecked-example <" USING: pair-rocket prettyprint ;

H{ "foo" => 1 "bar" => 2 } .
"> <" H{ { "foo" 1 } { "bar" 2 } } "> }
}
;

