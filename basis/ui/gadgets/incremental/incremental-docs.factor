USING: help.markup help.syntax ui.gadgets ui.gadgets.packs ;
IN: ui.gadgets.incremental

HELP: incremental
{ $class-description "Incremental layout gadgets inherit from " { $link pack } " and implement an optimization where the relayout operation after adding a child to be done in constant time."
$nl
"Incremental layout gadgets are created by calling " { $link <incremental> } "."
$nl
"Children are managed with the " { $link add-incremental } " and " { $link clear-incremental } " words."
$nl
"An example of an incremental is the 'output' of a 'pane' gadget."
$nl
"Not every " { $link pack } " can use incremental layout, since incremental layout does not support non-default values for the " { $slot "align" } ", " { $slot "fill" } ", and " { $slot "gap" } " slots." } ;

HELP: <incremental>
{ $values { "incremental" "a new instance of " { $link incremental } } }
{ $description "Creates a new incremental layout gadget." } ;

{ <incremental> add-incremental clear-incremental } related-words

HELP: add-incremental
{ $values { "gadget" gadget } { "incremental" incremental } }
{ $description "Adds the gadget to the incremental layout and performs relayout immediately in constant time." }
{ $side-effects "incremental" } ;

HELP: clear-incremental
{ $values { "incremental" incremental } }
{ $description "Removes all gadgets from the incremental layout and performs relayout immediately in constant time." }
{ $side-effects "incremental" } ;

ARTICLE: "ui-incremental-layout" "Incremental layouts"
"Incremental layout gadgets are like " { $link "ui-pack-layout" } " except the relayout operation after adding a new child can be done in constant time."
$nl
"With all layouts, relayout requests from consecutive additions and removals are of children are coalesced and result in only one relayout operation being performed, however the run time of the relayout operation itself depends on the number of children."
$nl
"Incremental layout is used by " { $link "ui.gadgets.panes" } " to ensure that new lines of output does not take longer to display when the pane already has previous output."
$nl
"Incremental layouts are not a general replacement for " { $link "ui-pack-layout" } " and there are some limitations to be aware of."
{ $subsections
    incremental
    <incremental>
}
"Children are added and removed with a special set of words which perform necessary relayout immediately:"
{ $subsections
    add-incremental
    clear-incremental
}
"Calling " { $link unparent } " to remove a child of an incremental layout is permitted, however the relayout following the removal will not be performed in constant time, because all gadgets following the removed gadget need to be moved." ;

ABOUT: "ui-incremental-layout"
