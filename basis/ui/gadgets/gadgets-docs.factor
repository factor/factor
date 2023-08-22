USING: accessors concurrency.flags help.markup help.syntax kernel
math.rectangles models strings ui.gadgets.private ;
IN: ui.gadgets

HELP: <gadget>
{ $values { "gadget" "a new " { $link gadget } } }
{ $description "Creates a new gadget." } ;

HELP: children-on
{ $values { "rect" rect } { "gadget" gadget } { "seq" "a sequence of gadgets" } }
{ $contract "Outputs a sequence of gadgets which potentially intersect a rectangle in the coordinate system of the gadget." }
{ $notes "This does not have to be an accurate intersection test, and simply returning " { $link children>> } " is a valid implementation. However, an accurate intersection test reduces the amount of work done when drawing this gadget if it is partially clipped and not all children are visible." } ;

HELP: control-value
{ $values { "control" gadget } { "value" object } }
{ $description "Outputs the value of the control's model." } ;

HELP: gadget-child
{ $values { "gadget" gadget } { "child" gadget } }
{ $description "Outputs the first child of the gadget. Typically this word is used with gadgets which are known to have only one child." } ;

HELP: notify
{ $values { "gadget" gadget } }
{ $description "Notifies the gadget that it has a graft message to handle." }
{ $see-also graft* ungraft* } ;

HELP: notify-ui-thread
{ $description "Notifies the UI thread that there is work to do." }
{ $see-also ui-notify-flag } ;

HELP: nth-gadget
{ $values { "n" "a non-negative integer" } { "gadget" gadget } { "child" gadget } }
{ $description "Outputs the " { $snippet "n" } "th child of the gadget." }
{ $errors "Throws an error if " { $snippet "n" } " is negative or greater than or equal to the number of children." } ;

HELP: relative-loc
{ $values { "fromgadget" gadget } { "togadget" gadget } { "loc" "a pair of integers" } }
{ $description
    "Outputs the location of the top-left corner of " { $snippet "togadget" } " relative to the coordinate system of " { $snippet "fromgadget" } "."
}
{ $errors
    "Throws an error if " { $snippet "togadget" } " is not contained in a child of " { $snippet "fromgadget" } "."
} ;

HELP: user-input*
{ $values { "str" string } { "gadget" gadget } { "?" boolean } }
{ $contract "Handle free-form textual input while the gadget has keyboard focus." } ;

HELP: temp-im-input
{ $values { "str" string } { "gadget" gadget } { "?" boolean } }
{ $contract "Handle free-form textual input while the gadget has keyboard focus. This is used to display the string being preedited by an input method on the gadget. Input by this word is not include changes in the Undo and Redo actions." } ;

HELP: pick-up
{ $values { "point" "a pair of integers" } { "gadget" gadget } { "child/f" { $maybe gadget } } }
{ $description "Outputs the child at a point in the gadget's coordinate system. This word recursively descends the gadget hierarchy, and so outputs the deepest child." } ;

HELP: max-dims
{ $values { "seq" "a sequence of pairs of integers" } { "dim" "a pair of integers" } }
{ $description "Outputs the smallest dimensions of a rectangle which can fit all the dimensions in the sequence." } ;

{ pref-dims max-dims sum-dims } related-words

HELP: each-child
{ $values { "gadget" gadget } { "quot" { $quotation ( child -- ) } } }
{ $description "Applies the quotation to each child of the gadget." } ;

HELP: gadget-selection?
{ $values { "gadget" gadget } { "?" boolean } }
{ $contract "Outputs if the gadget has an active text selection; if so, the selected text can be obtained with a call to " { $link gadget-selection } "." } ;

HELP: gadget-selection
{ $values { "gadget" gadget } { "string/f" { $maybe string } } }
{ $contract "Outputs the gadget's text selection, or " { $link f } " if nothing is selected." } ;

HELP: relayout
{ $values { "gadget" gadget } }
{ $description "Relayout and redraw a gadget before the next iteration of the event loop. Unlike " { $link relayout-1 } ", this relayouts all parents up to a gadget having " { $snippet "root?" } " set, so this word should be used when the gadget's dimensions have potentially changed." } ;

HELP: relayout-1
{ $values { "gadget" gadget } }
{ $description "Relayout and redraw a gadget before the next iteration of the event loop. Unlike " { $link relayout } ", this does not propagate requests up to the parent, and so this word should be used when the gadget's internal layout or appearance has changed, but the dimensions have not." } ;

{ relayout relayout-1 } related-words

HELP: pref-dim*
{ $values { "gadget" gadget } { "dim" "a pair of integers" } }
{ $contract "Outputs the preferred dimensions of the gadget, possibly computing them from the preferred dimensions of the gadget's children." }
{ $notes "User code should not call this word directly, instead call " { $link pref-dim } "." } ;

HELP: pref-dim
{ $values { "gadget" gadget } { "dim" "a pair of integers" } }
{ $description "Outputs the preferred dimensions of the gadget. The value is cached between calls, and invalidated when the gadget needs to be relayout." } ;

HELP: pref-dims
{ $values { "gadgets" "a sequence of gadgets" } { "seq" "a sequence of pairs of integers" } }
{ $description "Collects the preferred dimensions of every gadget in the sequence into a new sequence." } ;

HELP: layout*
{ $values { "gadget" gadget } }
{ $contract "Lays out the children of the gadget according to the gadget's policy. The dimensions of the gadget are already set by the parent by the time this word is called." }
{ $notes "User code should not call this word directly, instead call " { $link relayout } " and " { $link relayout-1 } "." } ;

HELP: prefer
{ $values { "gadget" gadget } }
{ $contract "Resizes the gadget to assume its preferred dimensions." } ;

HELP: sum-dims
{ $values { "seq" "a sequence of pairs of integers" } { "dim" "a pair of integers" } }
{ $description "Sums a sequence of dimensions." } ;

HELP: layout
{ $values { "gadget" gadget } }
{ $description "Lays out the children of the gadget if the gadget needs to be relayout, and otherwise does nothing." }
{ $notes "User code should not call this word directly, instead call " { $link relayout } " and " { $link relayout-1 } "." } ;

{ pref-dim pref-dim* layout layout* } related-words

HELP: graft*
{ $values { "gadget" gadget } }
{ $contract "Called to notify the gadget it has become visible on the screen. This should set up timers and threads, and acquire any resources used by the gadget." } ;

{ graft graft* ungraft ungraft* } related-words

HELP: ungraft*
{ $values { "gadget" gadget } }
{ $contract "Called to notify the gadget it is no longer visible on the screen. This should stop timers and threads, and release any resources used by the gadget." } ;

HELP: graft
{ $values { "gadget" gadget } }
{ $description "Calls " { $link graft* } " on the gadget and all children." }
{ $notes "This word should never be called directly." } ;

HELP: ungraft
{ $values { "gadget" gadget } }
{ $description "If the gadget is grafted, calls " { $link ungraft* } " on the gadget and all children." }
{ $notes "This word should never be called directly." } ;

HELP: unparent
{ $values { "gadget" gadget } }
{ $description "Removes the gadget from its parent. This will relayout the parent." }
{ $notes "This may result in " { $link ungraft* } " being called on the gadget and its children, if the gadget's parent is visible on the screen." } ;

HELP: clear-gadget
{ $values { "gadget" gadget } }
{ $description "Removes all children from the gadget. This will relayout the gadget." }
{ $notes "This may result in " { $link ungraft* } " being called on the children, if the gadget is visible on the screen." }
{ $side-effects "gadget" } ;

HELP: add-gadget
{ $values { "parent" gadget } { "child" gadget } }
{ $description "Adds a child gadget to a parent. If the gadget is contained in another gadget, " { $link unparent } " is called on the gadget first. The parent will be relayout." }
{ $notes "Adding a gadget to a parent may result in " { $link graft* } " being called on the children, if the parent is visible on the screen." }
{ $side-effects "parent" } ;

HELP: add-gadgets
{ $values { "parent" gadget } { "children" "a sequence of gadgets" } }
{ $description "Adds a sequence of gadgets to a parent. The parent will be relayout." }
{ $notes "This may result in " { $link graft* } " being called on the children, if the parent is visible on the screen." }
{ $side-effects "parent" } ;

HELP: child?
{ $values { "parent" gadget } { "child" gadget } { "?" boolean } }
{ $description "Tests if " { $snippet "child" } " is contained inside " { $snippet "parent" } "." } ;

HELP: each-parent
{ $values { "gadget" gadget } { "quot" { $quotation ( gadget -- ? ) } } { "?" boolean } }
{ $description "Applies the quotation to every parent of the gadget, starting from the gadget itself, stopping if the quotation yields " { $link f } ". Outputs " { $link t } " if the iteration completed, and outputs " { $link f } " if it was stopped prematurely." } ;

HELP: find-parent
{ $values { "gadget" gadget } { "quot" { $quotation ( gadget -- ? ) } } { "parent" gadget } }
{ $description "Outputs the first parent of the gadget, starting from the gadget itself, for which the quotation outputs a true value, or " { $link f } " if the quotation outputs " { $link f } " for every parent." } ;

HELP: focusable-child*
{ $values { "gadget" gadget } { "child/t" "a " { $link gadget } " or " { $link t } } }
{ $description "Outputs the child of the gadget which would prefer to receive keyboard focus, or " { $link t } " if the gadget itself should receive focus." }
{ $examples "For example, if your gadget consists of an editor together with an output area whose contents react to changes in editor contents, then the " { $link focusable-child* } " method for your gadget class should return the editor, so that when the gadget is displayed in a window or passed to " { $link request-focus } ", the editor receives keyboard focus automatically." } ;

HELP: focusable-child
{ $values { "gadget" gadget } { "child" gadget } }
{ $description "Outputs the child of the gadget which would prefer to receive keyboard focus." } ;

{ control-value set-control-value } related-words

HELP: layout-later
{ $values { "gadget" gadget } }
{ $description "Adds the gadget to the " { $link layout-queue } " and notifies the UI thread that there is a gadget to layout. If the length of the queue is larger than " { $link layout-queue-limit } ", then the current thread is yielded so that the UI thread has a chance to run." } ;

HELP: parents
{ $values { "gadget" gadget } { "seq" "a sequence of gadgets" } }
{ $description "Outputs a sequence of all parents of the gadget, with the first element being the gadget itself." } ;

HELP: screen-loc
{ $values { "gadget" gadget } { "loc" "a pair of integers" } }
{ $description "Outputs the location of the gadget relative to the top-left corner of the world containing the gadget. This word does not output a useful value if the gadget is not grafted." } ;

HELP: set-control-value
{ $values { "value" object } { "control" gadget } }
{ $description "Sets the value of the control's model." } ;

HELP: unqueue-graft
{ $values { "gadget" gadget } }
{ $description "Removes the gadget from the " { $link graft-queue } "." } ;

HELP: ui-notify-flag
{ $var-description "A " { $link flag } " raised to notify the UI thread that there is work to do." }
{ $see-also notify-ui-thread } ;

ARTICLE: "ui-control-impl" "Implementing controls"
"A " { $emphasis "control" } " is a gadget which is linked to an underlying " { $link model } " by having its " { $snippet "model" } " slot set to a " { $link model } " instance."
$nl
"Some utility words useful in control implementations:"
{ $subsections
    control-value
    set-control-value
}
"Graft handling:"
{ $subsections
  graft
  notify
  ungraft
  unqueue-graft
}
{ $see-also "models" } ;
