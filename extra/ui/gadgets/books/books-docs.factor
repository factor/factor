USING: ui.gadgets.books help.markup
help.syntax ui.gadgets models ;

HELP: book
{ $class-description "A book is a " { $link control } " containing one or more children. The " { $link control-value } " is the index of exactly one child to be visible at any one time, the rest being hidden by having their " { $link gadget-visible? } " slots set to " { $link f } ". The sole visible child assumes the dimensions of the book gadget."
$nl
"Books are created by calling " { $link <book> } "." } ;

HELP: <book>
{ $values { "pages" "a sequence of gadgets" } { "model" model } { "book" book } }
{ $description "Creates a " { $link book } { $link control } ", which contains the gadgets in " { $snippet "pages" } ". A book shows one child at a time, determined by the value of the model, which must be an integer " } ;
