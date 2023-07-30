USING: help.markup help.syntax kernel math.rectangles models
opengl.gl ui.gadgets ui.gadgets.worlds ui.gestures ui.pens ;
IN: ui.render

HELP: clip
{ $var-description "The current clipping rectangle." } ;

HELP: draw-gadget*
{ $values { "gadget" gadget } }
{ $contract "Draws the gadget by making OpenGL calls. The top-left corner of the gadget should be drawn at the location stored in the " { $link origin } " variable." }
{ $notes "This word should not be called directly. To force a gadget to redraw, call " { $link relayout-1 } "." } ;

HELP: gadget
{ $class-description "An object which displays itself on the screen and acts on user input gestures. Gadgets have the following slots:"
    { $slots
        { "pref-dim" { "a cached value for " { $link pref-dim } "; do not read or write this slot directly." } }
        { "parent" { "the gadget containing this one, or " { $link f } " if this gadget is not part of the visible gadget hierarchy." } }
        { "children" { "a vector of child gadgets. Do not modify this vector directly, instead use " { $link add-gadget } ", " { $link add-gadgets } ", " { $link unparent } " or " { $link clear-gadget } "." } }
        { "graft-state" { "a pair of " { $link boolean } " values that represent the current graft state of the gadget and what its next state will become." } }
        { "orientation" "an orientation specifier. This slot is used by layout gadgets." }
        { "layout-state" { "stores the layout state of the gadget. Do not read or write this slot directly, instead call " { $link relayout } " and " { $link relayout-1 } " if the gadget needs to be re-laid out." } }
        { "visible?" "a boolean indicating if the gadget should display and receive user input." }
        { "root?" { "if set to " { $link t } ", layout changes in this gadget will not propagate to the gadget's parent." } }
        { "clipped?" "a boolean indicating if clipping will be enabled when drawing this gadget's children." }
        { "interior" { "an implementation of the " { $link "ui-pen-protocol" } } }
        { "boundary" { "an implementation of the " { $link "ui-pen-protocol" } } }
        { "model" { "a " { $link model } " or " { $link f } "; see " { $link "ui-control-impl" } } }
    }
"Gadgets subclass the " { $link rect } " class, and thus all instances have " { $slot "loc" } " and " { $slot "dim" } " instances holding their location and dimensions." }
{ $notes
"Other classes may inherit from " { $link gadget } " in order to re-implement generic words such as " { $link draw-gadget* } " and " { $link user-input* } ", or to define gestures with " { $link set-gestures } "." } ;

HELP: gl-draw-init
{ $values { "world" world } }
{ $description "Does some OpenGL setup that is required each time the world is to be redrawn." } ;

ARTICLE: "ui-paint" "Customizing gadget appearance"
"The UI carries out the following steps when drawing a gadget:"
{ $list
    { "The " { $link draw-interior } " generic word is called on the value of the " { $slot "interior" } " slot." }
    { "The " { $link draw-gadget* } " generic word is called on the gadget." }
    { "The gadget's visible children are drawn, determined by calling " { $link visible-children } " on the gadget." }
    { "The " { $link draw-boundary } " generic word is called on the value of the " { $slot "boundary" } " slot." }
}
"Now, each one of these steps will be covered in detail."
{ $subsections
    "ui-pen-protocol"
    "ui-paint-custom"
} ;

ARTICLE: "ui-paint-coord" "The UI coordinate system"
"The UI uses a coordinate system where the y axis is oriented down. The OpenGL " { $link GL_MODELVIEW } " matrix is saved or restored when rendering a gadget, and the origin is translated to the gadget's origin within the window. The current origin is stored in a variable:"
{ $subsections origin }
"Gadgets must not draw outside of their bounding box, however clipping is not enforced by default, for performance reasons. This can be changed by setting the " { $slot "clipped?" } " slot to " { $link t } " in the gadget's constructor." ;

ABOUT: "ui-paint"
