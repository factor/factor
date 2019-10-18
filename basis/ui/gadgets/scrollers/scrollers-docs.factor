USING: ui.gadgets help.markup help.syntax ui.gadgets.viewports
ui.gadgets.sliders math.rectangles ui.gadgets.scrollers.private ;
IN: ui.gadgets.scrollers

HELP: scroller
{ $class-description "A scroller consists of a " { $link viewport } " containing a child, together with horizontal and vertical " { $link slider } " gadgets which scroll the viewport's child. Scroller gadgets also support using a mouse scroll wheel."
$nl
"Scroller gadgets are created by calling " { $link <scroller> } "." } ;

HELP: find-scroller
{ $values { "gadget" gadget } { "scroller/f" { $maybe scroller } } }
{ $description "Finds the first parent of " { $snippet "gadget" } " which is a " { $link scroller } ". Outputs " { $link f } " if the gadget is not contained in a " { $link scroller } "." } ;

HELP: scroll-position
{ $values { "scroller" scroller } { "loc" "a pair of integers" } }
{ $description "Outputs the offset of the top-left corner of the scroller's " { $link viewport } "'s child." } ;

{ scroll-position set-scroll-position scroll>bottom scroll>top scroll>rect } related-words

HELP: <scroller>
{ $values { "gadget" gadget } { "scroller" "a new " { $link scroller } } }
{ $description "Creates a new " { $link scroller } " for scrolling around " { $snippet "gadget" } "." } ;

{ <viewport> <scroller> } related-words

HELP: set-scroll-position
{ $values { "value" "a pair of integers" } { "scroller" scroller } }
{ $description "Sets the offset of the top-left corner of the scroller's " { $link viewport } "'s child." } ;

HELP: relative-scroll-rect
{ $values { "rect" rect } { "gadget" gadget } { "scroller" scroller } { "newrect" "a new " { $link rect } } }
{ $description "Adjusts " { $snippet "rect" } " for the case where the gadget is not the immediate child of the scroller's viewport." } ;

HELP: scroll>rect
{ $values { "rect" rect } { "gadget" gadget } }
{ $description "Ensures that a rectangular region relative to the top-left corner of " { $snippet "gadget" } " becomes visible in a " { $link scroller } " containing " { $snippet "gadget" } ". Does nothing if no parent of " { $snippet "gadget" } " is a " { $link scroller } "." } ;

HELP: scroll>bottom
{ $values { "gadget" gadget } }
{ $description "Ensures that any " { $link scroller } " containing " { $snippet "gadget" } " is scrolled all the way down. Does nothing if no parent of " { $snippet "gadget" } " is a " { $link scroller } "." } ;

HELP: scroll>top
{ $values { "gadget" gadget } }
{ $description "Ensures that any scroller containing " { $snippet "gadget" } " is scrolled all the way up. If no parent of " { $snippet "scroller" } " is a gadget, does nothing." } ;

ARTICLE: "ui.gadgets.scrollers" "Scroller gadgets"
"The " { $vocab-link "ui.gadgets.scrollers" } " vocabulary implements scroller gadgets. A scroller displays a gadget which is larger than the visible area."
{ $subsections
    scroller
    <scroller>
}
"Getting and setting the scroll position:"
{ $subsections
    scroll-position
    set-scroll-position
}
"Writing scrolling-aware gadgets:"
{ $subsections
    scroll>bottom
    scroll>top
    scroll>rect
    find-scroller
} ;

ABOUT: "ui.gadgets.scrollers"
