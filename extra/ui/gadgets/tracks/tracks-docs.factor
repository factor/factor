USING: ui.gadgets.tracks ui.gadgets.packs help.markup
help.syntax ui.gadgets arrays kernel quotations tuples ;

HELP: track
{ $class-description "A track is like a " { $link pack } " except each child is resized to a fixed multiple of the track's dimension in the direction of " { $link gadget-orientation } ". Tracks are created by calling " { $link <track> } "." } ;

HELP: <track>
{ $values { "orientation" "an orientation specifier" } { "track" "a new " { $link track } } }
{ $description "Creates a new track which lays out children along the given axis. Children are laid out vertically if the orientation is " { $snippet "{ 0 1 }" } " and horizontally if the orientation is " { $snippet "{ 1 0 }" } "." } ; 

{ <track> make-track build-track } related-words

HELP: track-add
{ $values { "gadget" gadget } { "track" track } { "constraint" "a number between 0 and 1, or " { $link f } } }
{ $description "Adds a new child to a track. If the constraint is " { $link f } ", the child always occupies its preferred size. Otherwise, the constrant is a fraction of the total size which is allocated for the child." } ;

HELP: track,
{ $values { "gadget" gadget } { "constraint" "a number between 0 and 1, or " { $link f } } }
{ $description "Adds a new child to a track. If the constraint is " { $link f } ", the child always occupies its preferred size. Otherwise, the constrant is a fraction of the total size which is allocated for the child. This word can only be called inside the quotation passed to " { $link make-track } " or " { $link build-track } "." } ;

HELP: make-track
{ $values { "quot" quotation } { "orientation" "an orientation specifier" } { "track" track } }
{ $description "Creates a new track. The quotation can add children by calling the " { $link track, } " word." } ;

HELP: build-track
{ $values { "tuple" tuple } { "quot" quotation } { "orientation" "an orientation specifier" } }
{ $description "Creates a new track and sets " { $snippet "tuple" } "'s delegate to the new track. The quotation can add children by calling the " { $link track, } " word, and access the track by calling " { $link g } " or " { $link g-> } "." } ;
