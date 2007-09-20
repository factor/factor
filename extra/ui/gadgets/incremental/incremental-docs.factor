USING: ui.gadgets help.markup help.syntax
ui.gadgets.incremental ui.gadgets.packs ;

HELP: incremental
{ $class-description "An incremental layout gadget delegates to a " { $link pack } " and implements an optimization which the relayout operation after adding a child to be done in constant time."
$nl
"Incremental layout gadgets are created by calling " { $link <incremental> } "."
$nl
"Children are managed with the " { $link add-incremental } " and " { $link clear-incremental } " words."
$nl
"Not every " { $link pack } " can use incremental layout, since incremental layout does not support non-default values for " { $link pack-align } ", " { $link pack-fill } ", and " { $link pack-gap } "." } ;

HELP: <incremental>
{ $values { "pack" pack } { "incremental" "a new instance of " { $link incremental } } }
{ $description "Creates a new incremental layout gadget delegating to " { $snippet "pack" } "." } ;

{ <incremental> add-incremental clear-incremental } related-words

HELP: add-incremental
{ $values { "gadget" gadget } { "incremental" incremental } }
{ $description "Adds the gadget to the incremental layout and performs relayout immediately in constant time." }
{ $side-effects "incremental" } ;

HELP: clear-incremental
{ $values { "incremental" incremental } }
{ $description "Removes all gadgets from the incremental layout and performs relayout immediately in constant time." }
{ $side-effects "incremental" } ;
