USING: ui.gadgets help.markup help.syntax opengl kernel strings
tuples classes quotations ;

HELP: rect
{ $class-description "A rectangle with the following slots:"
    { $list
        { { $link rect-loc } " - the top-left corner of the rectangle as an x/y pair" }
        { { $link rect-dim } " - the dimensions of the rectangle as a width/height pair" }
    }
    "Rectangles are constructed by calling " { $link <rect> } " and " { $link <extent-rect> } "."
} ;

HELP: <rect> ( loc dim -- rect )
{ $values { "loc" "a pair of integers" } { "dim" "a pair of integers" } { "rect" "a new " { $link rect } } }
{ $description "Creates a new rectangle with the specified top-left location and dimensions." } ;

{ <zero-rect> <rect> <extent-rect> } related-words

HELP: set-rect-dim ( dim rect -- )
{ $values { "dim" "a pair of integers" } { "rect" rect } }
{ $description "Modifies the dimensions of a rectangle. To resize a gadget, use " { $link set-gadget-dim } " or " { $link set-layout-dim } " instead." }
{ $side-effects "rect" } ;

HELP: rect-bounds
{ $values { "rect" rect } { "loc" "a pair of integers" } { "dim" "a pair of integers" } }
{ $description "Outputs the location and dimensions of a rectangle." } ;

{ rect-bounds rect-extent } related-words

HELP: <extent-rect> ( loc ext -- rect )
{ $values { "loc" "a pair of integers" } { "ext" "a pair of integers" } { "rect" "a new " { $link rect } } }
{ $description "Creates a new rectangle with the specified top-left and bottom-right corner locations." } ;

HELP: rect-extent
{ $values { "rect" rect } { "loc" "a pair of integers" } { "ext" "a pair of integers" } }
{ $description "Outputs the location of the top-left and bottom-right corners of a rectangle." } ;

HELP: offset-rect
{ $values { "rect" rect } { "loc" "a pair of integers" } { "newrect" "a new " { $link rect } } }
{ $description "Creates a new rectangle with the same dimensions, and top-left corner translated by " { $snippet "loc" } "." } ;

HELP: rect-intersect
{ $values { "rect1" rect } { "rect2" rect } { "newrect" "a new " { $link rect } } }
{ $description "Computes the intersection of two rectangles." } ;

HELP: intersects?
{ $values { "rect/point" "a " { $link rect } " or a pair of integers" } { "rect" rect } { "?" "a boolean" } }
{ $description "Tests if two rectangles (or a point and a rectangle, respectively) have a non-empty intersection." } ;

HELP: gadget-child
{ $values { "gadget" gadget } { "child" gadget } }
{ $description "Outputs the first child of the gadget. Typicallykernel.private this word is used with gadgets which are known to have an only child." } ;

HELP: nth-gadget
{ $values { "n" "a non-negative integer" } { "gadget" gadget } { "child" gadget } }
{ $description "Outputs the " { $snippet "n" } "th child of the gadget." }
{ $errors "Throws an error if " { $snippet "n" } " is negative or greater than or equal to the number of children." } ;

HELP: <zero-rect>
{ $values { "rect" "a new " { $link rect } } }
{ $description "Creates a rectangle located at the origin with zero dimensions." } ;

HELP: <gadget>
{ $values { "gadget" "a new " { $link gadget } } }
{ $description "Creates a new gadget." } ;

{ <gadget> set-gadget-delegate } related-words

HELP: relative-loc
{ $values { "fromgadget" gadget } { "togadget" gadget } { "loc" "a pair of integers" } }
{ $description
    "Outputs the location of the top-left corner of " { $snippet "togadget" } " relative to the co-ordinate system of " { $snippet "fromgadget" } "."
}
{ $errors
    "Throws an error if " { $snippet "togadget" } " is not contained in a child of " { $snippet "fromgadget" } "."
} ;

HELP: user-input*
{ $values { "str" string } { "gadget" gadget } { "?" "a boolean" } }
{ $contract "Handle free-form textual input while the gadget has keyboard focus." } ;

HELP: children-on
{ $values { "rect/point" "a " { $link rect } " or a pair of integers" } { "gadget" gadget } { "seq" "a sequence of gadgets" } }
{ $contract "Outputs a sequence of gadgets which potentially intersect a rectangle or contain a point in the co-ordinate system of the gadget." }
{ $notes "This does not have to be an accurate intersection test, and simply returning " { $link gadget-children } " is a valid implementation. However, an accurate intersection test reduces the amount of work done when drawing this gadget if it is partially clipped and not all children are visible." } ;

HELP: pick-up
{ $values { "point" "a pair of integers" } { "gadget" gadget } { "child/f" "a " { $link gadget } " or " { $link f } } }
{ $description "Outputs the child at a point in the gadget's co-ordinate system. This word recursively descends the gadget hierarchy, and so outputs the deepest child." } ;

HELP: max-dim
{ $values { "dims" "a sequence of pairs of integers" } { "dim" "a pair of integers" } }
{ $description "Outputs the smallest dimensions of a rectangle which can fit all the dimensions in the sequence." } ;

{ pref-dims max-dim dim-sum } related-words

HELP: each-child
{ $values { "gadget" gadget } { "quot" "a quotation with stack effect " { $snippet "( child -- )" } } }
{ $description "Applies the quotation to each child of the gadget." } ;

HELP: set-gadget-delegate
{ $values { "gadget" gadget } { "tuple" tuple } }
{ $description "Sets the delegate of " { $snippet "tuple" } " to " { $snippet "gadget" } ". This is like " { $link set-delegate } ", except that to ensure correct behavior, the parent of each child of " { $snippet "gadget" } " is changed to " { $snippet "tuple" } "." }
{ $notes "This word should be used instead of " { $link set-delegate } " when setting a tuple's delegate to a gadget." } ;

HELP: gadget-selection?
{ $values { "gadget" gadget } { "?" "a boolean" } }
{ $contract "Outputs if the gadget has an active text selection; if so, the selected text can be obtained with a call to " { $link gadget-selection } "." } ;

HELP: gadget-selection
{ $values { "gadget" gadget } { "string/f" "a " { $link string } " or " { $link f } } }
{ $contract "Outputs the gadget's text selection, or " { $link f } " if nothing is selected." } ;

HELP: relayout
{ $values { "gadget" gadget } }
{ $description "Relayout and redraw a gadget before the next iteration of the event loop. Unlike " { $link relayout-1 } ", this relayouts all parents up to a gadget having " { $link gadget-root? } " set, so this word should be used when the gadget's dimensions have potentially changed." } ;

HELP: relayout-1
{ $values { "gadget" gadget } }
{ $description "Relayout and redraw a gadget before the next iteration of the event loop. Unlike " { $link relayout } ", this does not propagate requests up to the parent, and so this word should only be used when the gadget's internal layout or appearance has changed, but the dimensions have not." } ;

{ relayout relayout-1 } related-words

HELP: set-layout-dim
{ $values { "dim" "a pair of integers" } { "gadget" gadget } }
{ $description "Resizes a gadget inside a " { $link layout* } " method." }
{ $warning "Do not call this word outside of a " { $link layout* } " method, or otherwise the gadget will not be relayout automatically. Instead, use " { $link set-gadget-dim } "." } ;

HELP: set-gadget-dim
{ $values { "dim" "a pair of integers" } { "gadget" gadget } }
{ $description "Resizes and relayouts a gadget before the next iteration of the event loop." }
{ $warning "Do not call this word inside a " { $link layout* } " method, or otherwise unnecessary work will be done by the UI to ensure the gadget is relayout. Instead, use " { $link set-layout-dim } "." } ;

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

HELP: dim-sum
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
{ $values { "gadget" gadget } { "parent" gadget } }
{ $description "Adds a child gadget to a parent. If the gadget is contained in another gadget, " { $link unparent } " is called on the gadget first. The parent will be relayout." }
{ $notes "Adding a gadget to a parent may result in " { $link graft* } " being called on the children, if the parent is visible on the screen." }
{ $side-effects "parent" } ;

HELP: add-gadgets
{ $values { "seq" "a sequence of gadgets" } { "parent" gadget } }
{ $description "Adds a sequence of gadgets to a parent. The parent will be relayout." }
{ $notes "This may result in " { $link graft* } " being called on the children, if the parent is visible on the screen." }
{ $side-effects "parent" } ;

HELP: parents
{ $values { "gadget" gadget } { "seq" "a sequence of gadgets" } }
{ $description "Outputs a sequence of all parents of the gadget, with the first element being the gadget itself." } ;

HELP: each-parent
{ $values { "gadget" gadget } { "quot" "a quotation with stack effect " { $snippet "( gadget -- ? )" } } { "?" "a boolean" } }
{ $description "Applies the quotation to every parent of the gadget, starting from the gadget itself, stopping if the quotation yields " { $link f } ". Outputs " { $link t } " if the iteration completed, and outputs " { $link f } " if it was stopped prematurely." } ;

HELP: find-parent
{ $values { "gadget" gadget } { "quot" "a quotation with stack effect " { $snippet "( gadget -- ? )" } } { "parent" gadget } }
{ $description "Outputs the first parent of the gadget, starting from the gadget itself, for which the quotation outputs a true value, or " { $link f } " if the quotation outputs " { $link f } " for every parent." } ;

HELP: screen-loc
{ $values { "gadget" gadget } { "loc" "a pair of integers" } }
{ $description "Outputs the location of the gadget relative to the top-left corner of the world containing the gadget. This word does not output a useful value if the gadget is not grafted." } ;

HELP: child?
{ $values { "parent" gadget } { "child" gadget } { "?" "a boolean" } }
{ $description "Tests if " { $snippet "child" } " is contained inside " { $snippet "parent" } "." } ;

HELP: focusable-child*
{ $values { "gadget" gadget } { "child/t" "a " { $link gadget } " or " { $link t } } }
{ $description "Outputs the child of the gadget which would prefer to receive keyboard focus, or " { $link t } " if the gadget itself should receive focus." }
{ $examples "For example, if your gadget consists of an editor together with an output area whose contents react to changes in editor contents, then the " { $link focusable-child* } " method for your gadget class should return the editor, so that when the gadget is displayed in a window or passed to " { $link request-focus } ", the editor receives keyboard focus automatically." } ;

HELP: focusable-child
{ $values { "gadget" gadget } { "child" gadget } }
{ $description "Outputs the child of the gadget which would prefer to receive keyboard focus." } ;

HELP: gadget,
{ $values { "gadget" gadget } }
{ $description "Adds a new child to the gadget being constructed. This word can only be used from a quotation passed to " { $link make-gadget } " or " { $link build-gadget } "." } ;

HELP: make-gadget
{ $values { "quot" quotation } { "gadget" gadget } }
{ $description "Calls the quotation in a new scope with the gadget stored in the " { $link make-gadget } " variable." } ;

HELP: build-gadget
{ $values { "tuple" tuple } { "quot" quotation } { "gadget" gadget } }
{ $description "Delegates the tuple to the gadget, and calls the quotation in a new scope with the tuple stored in the " { $link make-gadget } " and " { $link gadget } " variables." } ;

HELP: with-gadget
{ $values { "gadget" gadget } { "quot" quotation } } 
{ $description "Calls the quotation in a new scope with the " { $link gadget } " and " { $link make-gadget } " variables set to " { $snippet "gadget" } ". The quotation can call " { $link g } " and " { $link g-> } " to access the gadget." } ;

HELP: g
{ $values { "gadget" gadget } }
{ $description "Outputs the gadget being built. Can only be used inside a quotation passed to " { $link build-gadget } "." } ;

HELP: g->
{ $values { "x" object } { "gadget" gadget } }
{ $description "Duplicates the top of the stack and outputs the gadget being built. Can only be used inside a quotation passed to " { $link build-gadget } "." } ;
