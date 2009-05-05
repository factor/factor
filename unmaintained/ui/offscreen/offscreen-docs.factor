! Copyright (C) 2008 Joe Groff.
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax kernel quotations ui.gadgets
images strings ui.gadgets.worlds ;
IN: ui.offscreen

HELP: <offscreen-world>
{ $values
     { "gadget" gadget } { "title" string } { "status" "a boolean" }
     { "world" offscreen-world }
}
{ $description "Constructs an " { $link offscreen-world } " gadget with " { $snippet "gadget" } " as its only child. Generally you should use " { $link open-offscreen } " or " { $link do-offscreen } " instead of calling this word directly." } ;

HELP: close-offscreen
{ $values
     { "world" offscreen-world }
}
{ $description "Releases the resources used by the rendering buffer for " { $snippet "world" } "." } ;

HELP: do-offscreen
{ $values
     { "gadget" gadget } { "quot" quotation }
}
{ $description "Constructs an " { $link offscreen-world } " around " { $snippet "gadget" } " with " { $link open-offscreen } ", calls " { $snippet "quotation" } " with the world on the top of the stack, and cleans up the world with " { $link close-offscreen } " at the end of " { $snippet "quotation" } "." } ;

HELP: gadget>bitmap
{ $values
     { "gadget" gadget }
     { "image" image }
}
{ $description "Renders " { $snippet "gadget" } " to an " { $link offscreen-world } " and creates an " { $link image } " from its contents." } ;

HELP: offscreen-world
{ $class-description "The class of " { $link world } " objects that render to an offscreen buffer." } ;

HELP: offscreen-world>bitmap
{ $values
     { "world" offscreen-world }
     { "image" image }
}
{ $description "Saves a copy of the contents of " { $snippet "world" } " to a " { $link image } " object." } ;

HELP: open-offscreen
{ $values
     { "gadget" gadget }
     { "world" offscreen-world }
}
{ $description "Creates and sets up an " { $link offscreen-world } " with " { $snippet "gadget" } " as its only child." } ;

{ offscreen-world open-offscreen close-offscreen do-offscreen } related-words

ARTICLE: "ui.offscreen" "Offscreen UI rendering"
"The " { $vocab-link "ui.offscreen" } " provides words for rendering gadgets to an offscreen buffer so that bitmaps can be made from their contents."
{ $subsection offscreen-world }
"Opening gadgets offscreen:"
{ $subsection open-offscreen }
{ $subsection close-offscreen }
{ $subsection do-offscreen }
"Creating bitmaps from offscreen buffers:"
{ $subsection offscreen-world>bitmap }
{ $subsection gadget>bitmap } ;

ABOUT: "ui.offscreen"
