USING: ui.gadgets ui.gestures help.markup help.syntax
kernel classes strings opengl.gl ;
IN: ui.render

HELP: gadget
{ $class-description "An object which displays itself on the screen and acts on user input gestures. Gadgets have the following slots:"
    { $list
        { { $link gadget-pref-dim } " - a cached value for " { $link pref-dim } "; do not read or write this slot directly." }
        { { $link gadget-parent } " - the gadget containing this one, or " { $link f } " if this gadget is not part of the visible gadget hierarchy." }
        { { $link gadget-children } " - a vector of child gadgets. Do not modify this vector directly, instead use " { $link add-gadget } ", " { $link add-gadgets } ", " { $link unparent } " or " { $link clear-gadget } "." }
        { { $link gadget-orientation } " - an orientation specifier. This slot is used by layout gadgets." }
        { { $link gadget-state } " - stores the layout state of the gadget. Do not read or write this slot directly, instead call " { $link relayout } " and " { $link relayout-1 } " if the gadget needs to be re-laid out." }
        { { $link gadget-visible? } " - a boolean indicating if the gadget should display and receive user input." }
        { { $link gadget-root? } " - if set to " { $link t } ", layout changes in this gadget will not propagate to the gadget's parent." }
        { { $link gadget-clipped? } " - a boolean indicating if clipping will be enabled when drawing this gadget's children." }
        { { $link gadget-grafted? } " - if set to " { $link t } ", the gadget is parented in a native window." }
        { { $link gadget-interior } " - an object whose class implements the " { $link draw-interior } " generic word." }
        { { $link gadget-boundary } " - an object whose class implements the " { $link draw-boundary } " generic word." }
    }
"Gadgets delegate to " { $link rect } " instances holding their location and dimensions." }
{ $notes
"Other classes may delegate to " { $link gadget } " in order to re-implement generic words such as " { $link draw-gadget* } " and " { $link user-input* } ", or to define gestures with " { $link set-gestures } "." }
{ $warning
"When setting a tuple's delegate to be a gadget, " { $link set-gadget-delegate } " should be used instead of " { $link set-delegate } "." } ;

HELP: clip
{ $var-description "The current clipping rectangle." } ;

HELP: draw-gadget*
{ $values { "gadget" gadget } } 
{ $contract "Draws the gadget by making OpenGL calls. The top-left corner of the gadget should be drawn at the location stored in the " { $link origin } " variable." }
{ $notes "This word should not be called directly. To force a gadget to redraw, call " { $link relayout-1 } "." } ;

HELP: draw-interior
{ $values { "interior" object } { "gadget" gadget } } 
{ $contract "Draws the interior of a gadget by making OpenGL calls. The " { $link gadget-interior } " slot may be set to objects implementing this generic word." } ;

HELP: draw-boundary
{ $values { "boundary" object } { "gadget" gadget } } 
{ $contract "Draws the boundary of a gadget by making OpenGL calls. The " { $link gadget-boundary } " slot may be set to objects implementing this generic word." } ;

HELP: solid
{ $class-description "A class implementing the " { $link draw-boundary } " and " { $link draw-interior } " generic words to draw a solid outline or a solid fill, respectively. The " { $link solid-color } " slot stores a color specifier." } ;

HELP: gradient
{ $class-description "A class implementing the " { $link draw-interior } " generic word to draw a smoothly shaded transition between colors. The " { $link gradient-colors } " slot stores a sequence of color specifiers and the gradient is drawn in the direction given by the " { $link gadget-orientation } " slot of the gadget." } ;

HELP: polygon
{ $class-description "A class implementing the " { $link draw-boundary } " and " { $link draw-interior } " generic words to draw a solid outline or a solid filled polygon, respectively. Instances of " { $link polygon } " have two slots:"
    { $list
        { { $link polygon-color } " - a color specifier" }
        { { $link polygon-points } " - a sequence of points" }
    }
} ;

HELP: <polygon>
{ $values { "color" "a color specifier" } { "points" "a sequence of points" } }
{ $description "Creates a new instance of " { $link polygon } "." } ;

HELP: <polygon-gadget>
{ $values { "color" "a color specifier" } { "points" "a sequence of points" } { "gadget" "a new " { $link gadget } } }
{ $description "Creates a gadget which is drawn as a solid filled polygon. The gadget's size is the minimum bounding box containing all the points of the polygon." } ;

HELP: open-font
{ $values { "font" "a font specifier" } { "open-font" object } }
{ $description "Loads a font if it has not already been loaded, otherwise outputs the existing font." }
{ $errors "Throws an error if the font does not exist." } ;

HELP: string-width
{ $values { "open-font" "a value output by " { $link open-font } } { "string" string } { "w" "a positive integer" } }
{ $description "Outputs the width of a string." } ;

HELP: text-dim
{ $values { "open-font" "a value output by " { $link open-font } } { "text" "a string or an array of strings" } { "dim" "a pair of integers" } }
{ $description "Outputs the dimensions of a piece of text, which is either a single-line string or an array of lines." } ;

HELP: draw-string
{ $values { "font" "a font specifier" } { "string" string } { "loc" "a pair of integers" } }
{ $description "Draws a line of text." } ;

HELP: draw-text
{ $values { "font" "a font specifier" } { "text" "a string or an array of strings" } { "loc" "a pair of integers" } }
{ $description "Draws text. Text is either a single-line string or an array of lines." } ;

ARTICLE: "gadgets-polygons" "Polygon gadgets"
"A polygon gadget renders a simple shaded polygon."
{ $subsection <polygon-gadget> }
"Some pre-made polygons:"
{ $subsection arrow-up }
{ $subsection arrow-right }
{ $subsection arrow-down }
{ $subsection arrow-left }
{ $subsection close-box }
"Polygon gadgets are rendered by the " { $link polygon } " pen protocol implementation." ;

ARTICLE: "ui-paint" "Customizing gadget appearance"
"The UI carries out the following steps when drawing a gadget:"
{ $list
    { "The " { $link draw-interior } " generic word is called on the value of the " { $link gadget-interior } " slot." }
    { "The " { $link draw-gadget* } " generic word is called on the gadget." }
    { "The gadget's visible children are drawn, determined by calling " { $link visible-children } " on the gadget." }
    { "The " { $link draw-boundary } " generic word is called on the value of the " { $link gadget-boundary } " slot." }
}
"Now, each one of these steps will be covered in detail."
{ $subsection "ui-pen-protocol" }
{ $subsection "ui-paint-custom" } ;

ARTICLE: "ui-pen-protocol" "UI pen protocol"
"The " { $link gadget-interior } " and " { $link gadget-boundary } " slots of a gadget facilitate easy factoring and sharing of drawing logic. Objects stored in these slots must implement the pen protocol:"
{ $subsection draw-interior }
{ $subsection draw-boundary }
"The default value of these slots is the " { $link f } " singleton, which implements the above protocol by doing nothing."
$nl
"Some other pre-defined implementations:"
{ $subsection solid }
{ $subsection gradient }
{ $subsection polygon }
"Custom implementations must follow the guidelines set forth in " { $link "ui-paint-custom" } "." ;

ARTICLE: "text-rendering" "Rendering text"
"Unlike OpenGL, Factor's FreeType binding only includes the bare essentials, and there is rarely any need to directly call words in the " { $vocab-link "freetype" } " vocabulary directly. Instead, the UI provides high-level wrappers."
$nl
"Font objects are never constructed directly, and instead are obtained by calling a word:"
{ $subsection open-font }
"Measuring text:"
{ $subsection text-dim }
{ $subsection text-height }
{ $subsection text-width }
"Rendering text:"
{ $subsection draw-string }
{ $subsection draw-text } ;

ARTICLE: "ui-paint-custom" "Implementing custom drawing logic"
"The UI uses OpenGL to render gadgets. Custom rendering logic can be plugged in with the " { $link "ui-pen-protocol" } ", or by implementing a generic word:"
{ $subsection draw-gadget* }
"Custom drawing code has access to the full OpenGL API in the " { $vocab-link "opengl" } " vocabulary."
$nl
"The UI uses a co-ordinate system where the y axis is oriented down. The OpenGL " { $link GL_MODELVIEW } " matrix is not saved or restored when rendering a gadget. Instead, the origin of the gadget relative to the OpenGL context is stored in a variable:"
{ $subsection origin }
"Custom drawing implementations can translate co-ordinates manually, or save and restore the " { $link GL_MODELVIEW } " matrix."
$nl
"OpenGL state must not be altered as a result of drawing a gadget, so any flags which were enabled should be disabled, and vice versa."
$nl
"Gadgets must not draw outside of their bounding box, however clipping is not enforced by default, for performance reasons. This can be changed by setting the " { $link gadget-clipped? } " slot to " { $link t } " in the gadget's constructor."
$nl
"Saving the " { $link GL_MODELVIEW } " matrix and enabling/disabling flags can be done in a clean way using the combinators documented in the following section."
{ $subsection "gl-utilities" }
{ $subsection "text-rendering" } ;

ABOUT: "ui-paint-custom"
