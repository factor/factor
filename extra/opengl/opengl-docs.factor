USING: help.markup help.syntax io kernel math quotations
opengl.gl ;
IN: opengl

HELP: gl-color
{ $values { "color" "a color specifier" } }
{ $description "Wrapper for " { $link glColor4d } " taking a color specifier." } ;

HELP: gl-error
{ $description "If the most recent OpenGL call resulted in an error, print the error to the " { $link stdio } " stream." } ;

HELP: do-state
{ $values { "what" integer } { "quot" quotation } }
{ $description "Wraps a quotation in " { $link glBegin } "/" { $link glEnd } " calls." } ;

HELP: do-enabled
{ $values { "what" integer } { "quot" quotation } }
{ $description "Wraps a quotation in " { $link glEnable } "/" { $link glDisable } " calls." } ;

HELP: do-matrix
{ $values { "mode" { $link GL_MODELVIEW } " or " { $link GL_PROJECTION } } { "quot" quotation } }
{ $description "Saves and restores the matrix specified by " { $snippet "mode" } " before and after calling the quotation." } ;

HELP: gl-vertex
{ $values { "point" "a pair of integers" } }
{ $description "Wrapper for " { $link glVertex2d } " taking a point object." } ;

HELP: gl-line
{ $values { "a" "a pair of integers" } { "b" "a pair of integers" } }
{ $description "Draws a line between two points." } ;

HELP: gl-fill-rect
{ $values { "loc" "a pair of integers" } { "ext" "a pair of integers" } }
{ $description "Draws a filled rectangle with top-left corner " { $snippet "loc" } " and bottom-right corner " { $snippet "ext" } "." } ;

HELP: gl-rect
{ $values { "loc" "a pair of integers" } { "ext" "a pair of integers" } }
{ $description "Draws the outline of a rectangle with top-left corner " { $snippet "loc" } " and bottom-right corner " { $snippet "ext" } "." } ;

HELP: gl-fill-poly
{ $values { "points" "a sequence of pairs of integers" } }
{ $description "Draws a filled polygon." } ;

HELP: gl-poly
{ $values { "points" "a sequence of pairs of integers" } }
{ $description "Draws the outline of a polygon." } ;

HELP: gl-gradient
{ $values { "direction" "an orientation specifier" } { "colors" "a sequence of color specifiers" } { "dim" "a pair of integers" } }
{ $description "Draws a rectangle with top-left corner " { $snippet "{ 0 0 }" } " and dimensions " { $snippet "dim" } ", filled with a smoothly shaded transition between the colors in " { $snippet "colors" } "." } ;

HELP: gen-texture
{ $values { "id" integer } }
{ $description "Wrapper for " { $link glGenTextures } " to handle the common case of generating a single texture ID." } ;

HELP: do-attribs
{ $values { "bits" integer } { "quot" quotation } }
{ $description "Wraps a quotation in " { $link glPushAttrib } "/" { $link glPopAttrib } " calls." } ;

HELP: sprite
{ $class-description "A sprite is an OpenGL texture together with a display list which renders a textured quad. Sprites are used to draw text in the UI. Sprites have the following slots:"
    { $list
        { { $link sprite-dlist } " - an OpenGL display list ID" }
        { { $link sprite-texture } " - an OpenGL texture ID" }
        { { $link sprite-loc } " - top-left corner of the sprite" }
        { { $link sprite-dim } " - dimensions of the sprite" }
        { { $link sprite-dim2 } " - dimensions of the sprite, rounded up to the nearest powers of two" }
    }
} ;

HELP: gray-texture
{ $values { "sprite" sprite } { "pixmap" "an alien or byte array" } { "id" "an OpenGL texture ID" } }
{ $description "Creates a new OpenGL texture from a 1 byte per pixel image whose dimensions are equal to " { $link sprite-dim2 } "." } ;

HELP: gen-dlist
{ $values { "id" integer } }
{ $description "Wrapper for " { $link glGenLists } " to handle the common case of generating a single display list ID." } ;

HELP: make-dlist
{ $values { "type" "one of " { $link GL_COMPILE } " or " { $link GL_COMPILE_AND_EXECUTE } } { "quot" quotation } { "id" "an OpenGL texture ID" } }
{ $description "Compiles the results of calling the quotation into a new OpenGL display list." } ;

HELP: gl-translate
{ $values { "point" "a pair of integers" } }
{ $description "Wrapper for " { $link glTranslated } " taking a point object." } ;

HELP: free-sprites
{ $values { "sprites" "a sequence of " { $link sprite } " instances" } }
{ $description "Deallocates native resources associated toa  sequence of sprites." } ;

HELP: with-translation
{ $values { "loc" "a pair of integers" } { "quot" quotation } }
{ $description "Calls the quotation with a translation by " { $snippet "loc" } " pixels applied to the current " { $link GL_MODELVIEW } " matrix, restoring the matrix when the quotation is done." } ;

ARTICLE: "gl-utilities" "OpenGL utility words"
"In addition to the full OpenGL API, the " { $vocab-link "opengl" } " vocabulary includes some utility words to give OpenGL a more Factor-like feel."
$nl
"Wrappers:"
{ $subsection gl-color }
{ $subsection gl-vertex }
{ $subsection gl-translate }
"Combinators:"
{ $subsection do-state }
{ $subsection do-enabled }
{ $subsection do-attribs }
{ $subsection do-matrix }
{ $subsection with-translation }
{ $subsection make-dlist }
"Rendering geometric shapes:"
{ $subsection gl-line }
{ $subsection gl-fill-rect }
{ $subsection gl-rect }
{ $subsection gl-fill-poly }
{ $subsection gl-poly }
{ $subsection gl-gradient } ;

ABOUT: "gl-utilities"
