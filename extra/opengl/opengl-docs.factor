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

HELP: rect-vertices
{ $values { "lower-left" "A pair of numbers indicating the lower-left coordinates of the rectangle." } { "upper-right" "The upper-right coordinates of the rectangle." } }
{ $description "Emits" { $link glVertex2d } " calls outlining the axis-aligned rectangle from " { $snippet "lower-left" } to { $snippet "upper-right" } " on the z=0 plane in counterclockwise order." } ;

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

HELP: gen-framebuffer
{ $values { "id" integer } }
{ $description "Wrapper for " { $link glGenFramebuffersEXT } " to handle the common case of generating a single framebuffer ID." } ;

HELP: gen-renderbuffer
{ $values { "id" integer } }
{ $description "Wrapper for " { $link glGenRenderbuffersEXT } " to handle the common case of generating a single render buffer ID." } ;

HELP: gen-buffer
{ $values { "id" integer } }
{ $description "Wrapper for " { $link glGenBuffers } " to handle the common case of generating a single buffer ID." } ;

HELP: delete-texture
{ $values { "id" integer } }
{ $description "Wrapper for " { $link glDeleteTextures } " to handle the common case of deleting a single texture ID." } ;

HELP: delete-framebuffer
{ $values { "id" integer } }
{ $description "Wrapper for " { $link glDeleteFramebuffersEXT } " to handle the common case of deleting a single framebuffer ID." } ;

HELP: delete-renderbuffer
{ $values { "id" integer } }
{ $description "Wrapper for " { $link glDeleteRenderbuffersEXT } " to handle the common case of deleting a single render buffer ID." } ;

HELP: delete-buffer
{ $values { "id" integer } }
{ $description "Wrapper for " { $link glDeleteBuffers } " to handle the common case of deleting a single buffer ID." } ;

{ gen-texture delete-texture } related-words
{ gen-framebuffer delete-framebuffer } related-words
{ gen-renderbuffer delete-renderbuffer } related-words
{ gen-buffer delete-buffer } related-words

HELP: framebuffer-incomplete?
{ $values { "status/f" "The framebuffer error code, or " { $snippet "f" } " if the framebuffer is render-complete." } }
{ $description "Checks the framebuffer currently bound by " { $link glBindFramebufferEXT } " or " { $link with-framebuffer } " to see if it is incomplete, i.e., it is not ready to be rendered to." } ;

HELP: check-framebuffer
{ $description "Checks the framebuffer currently bound by " { $link glBindFramebufferEXT } " or " { $link with-framebuffer } " with " { $link framebuffer-incomplete? } ", and throws a descriptive error if the framebuffer is incomplete." } ;

HELP: with-framebuffer
{ $values { "id" "The id of a framebuffer object." } { "quot" "a quotation" } }
{ $description "Binds framebuffer " { $snippet "id" } " while calling " { $snippet "quot" } ", restoring the window framebuffer when finished." } ;

HELP: bind-texture-unit
{ $values { "id" "The id of a texture object." } { "target" "The texture target (e.g., " { $snippet "GL_TEXTURE_2D" } ")" } { "unit" "The texture unit to bind (e.g., " { $snippet "GL_TEXTURE0" } ")" } }
{ $description "Binds texture " { $snippet "id" } " to texture target " { $snippet "target" } " of texture unit " { $snippet "unit" } ". Equivalent to " { $snippet "unit glActiveTexture target id glBindTexture" } "." } ;

HELP: set-draw-buffers
{ $values { "buffers" "A sequence of buffer words (e.g. " { $snippet GL_BACK } ", " { $snippet GL_COLOR_ATTACHMENT0_EXT } ")"} }
{ $description "Wrapper for " { $link glDrawBuffers } ". Sets up the buffers named in the sequence for simultaneous drawing." } ;

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

HELP: gl-shader
{ $class-description { $snippet "gl-shader" } " is a predicate class comprising values returned by OpenGL to represent shader objects. The following words are provided for creating and manipulating these objects:"
    { $list
        { { $link <gl-shader> } " - Compile GLSL code into a shader object" }
        { { $link gl-shader-ok? } " - Check whether a shader object compiled successfully" }
        { { $link check-gl-shader } " - Throw an error unless a shader object compiled successfully" }
        { { $link gl-shader-info-log } " - Retrieve the info log of messages generated by the GLSL compiler" }
        { { $link delete-gl-shader } " - Invalidate a shader object" }
    }
  "The derived predicate classes " { $link vertex-shader } " and " { $link fragment-shader } " are also defined for the two standard kinds of shader defined by the OpenGL specification." } ;

HELP: vertex-shader
{ $class-description { $snippet "vertex-shader" } " is the predicate class of " { $link gl-shader } " objects that refer to shaders of type " { $snippet "GL_VERTEX_SHADER" } ". In addition to the " { $snippet "gl-shader" } " words, the following vertex shader-specific functions are defined:"
    { $list
        { { $link <vertex-shader> } " - Compile GLSL code into a vertex shader object "}
    }
} ;

HELP: fragment-shader
{ $class-description { $snippet "fragment-shader" } " is the predicate class of " { $link gl-shader } " objects that refer to shaders of type " { $snippet "GL_FRAGMENT_SHADER" } ". In addition to the " { $snippet "gl-shader" } " words, the following fragment shader-specific functions are defined:"
    { $list
        { { $link <fragment-shader> } " - Compile GLSL code into a fragment shader object "}
    }
} ;

HELP: <gl-shader>
{ $values { "source" "The GLSL source code to compile" } { "kind" "The kind of shader to compile, such as " { $snippet "GL_VERTEX_SHADER" } " or " { $snippet "GL_FRAGMENT_SHADER" } } }
{ $description "Tries to compile the given GLSL source into a shader object. The returned object can be checked for validity by " { $link check-gl-shader } " or " { $link gl-shader-ok? } ". Errors and warnings generated by the GLSL compiler will be collected in the info log, available from " { $link gl-shader-info-log } ".\n\nWhen the shader object is no longer needed, it should be deleted using " { $link delete-gl-shader } " or else be attached to a " { $link gl-program } " object deleted using " { $link delete-gl-program } "." } ;

HELP: <vertex-shader>
{ $values { "source" "The GLSL source code to compile" } }
{ $description "Tries to compile the given GLSL source into a vertex shader object. Equivalent to " { $snippet "GL_VERTEX_SHADER <gl-shader>" } "." } ;

HELP: <fragment-shader>
{ $values { "source" "The GLSL source code to compile" } }
{ $description "Tries to compile the given GLSL source into a fragment shader object. Equivalent to " { $snippet "GL_FRAGMENT_SHADER <gl-shader>" } "." } ;

HELP: gl-shader-ok?
{ $values { "shader" "A " { $link gl-shader } " object" } }
{ $description "Returns a boolean value indicating whether the given shader object compiled successfully. Compilation errors and warnings are available in the shader's info log, which can be gotten using " { $link gl-shader-info-log } "." } ;

HELP: check-gl-shader
{ $values { "shader" "A " { $link gl-shader } " object" } }
{ $description "Throws an error containing the " { $link gl-shader-info-log } " for the shader object if it failed to compile. Otherwise, the shader object is left on the stack." } ;

HELP: delete-gl-shader
{ $values { "shader" "A " { $link gl-shader } " object" } }
{ $description "Deletes the shader object, invalidating it and releasing any resources allocated for it by the OpenGL implementation." } ;

HELP: gl-shader-info-log
{ $values { "shader" "A " { $link gl-shader } " object" } }
{ $description "Retrieves the info log for " { $snippet "shader" } ", including any errors or warnings generated in compiling the shader object." } ;

HELP: gl-program
{ $class-description { $snippet "gl-program" } " is a predicate class comprising values returned by OpenGL to represent proram objects. The following words are provided for creating and manipulating these objects:"
    { $list
        { { $link <gl-program> } ", " { $link <simple-gl-program> } " - Link a set of shaders into a GLSL program" }
        { { $link gl-program-ok? } " - Check whether a program object linked successfully" }
        { { $link check-gl-program } " - Throw an error unless a program object linked successfully" }
        { { $link gl-program-info-log } " - Retrieve the info log of messages generated by the GLSL linker" }
        { { $link gl-program-shaders } " - Retrieve the set of shader objects composing the GLSL program" }
        { { $link delete-gl-program } " - Invalidate a program object and all its attached shaders" }
        { { $link with-gl-program } " - Use a program object" }
    }
} ;

HELP: <gl-program>
{ $values { "shaders" "A sequence of " { $link gl-shader } " objects." } }
{ $description "Creates a new GLSL program object, attaches all the shader objects in the " { $snippet "shaders" } " sequence, and attempts to link them. The returned object can be checked for validity by " { $link check-gl-program } " or " { $link gl-program-ok? } ". Errors and warnings generated by the GLSL linker will be collected in the info log, available from " { $link gl-program-info-log } ".\n\nWhen the program object and its attached shaders are no longer needed, it should be deleted using " { $link delete-gl-program } "." } ;

HELP: <simple-gl-program>
{ $values { "vertex-shader-source" "A string containing GLSL vertex shader source" } { "fragment-shader-source" "A string containing GLSL fragment shader source" } }
{ $description "Wrapper for " { $link <gl-program> } " for the simple case of compiling a single vertex shader and fragment shader and linking them into a GLSL program. Throws an exception if compiling or linking fails." } ;

{ <gl-program> <simple-gl-program> } related-words

HELP: gl-program-ok?
{ $values { "program" "A " { $link gl-program } " object" } }
{ $description "Returns a boolean value indicating whether the given program object linked successfully. Link errors and warnings are available in the program's info log, which can be gotten using " { $link gl-program-info-log } "." } ;

HELP: check-gl-program
{ $values { "program" "A " { $link gl-program } " object" } }
{ $description "Throws an error containing the " { $link gl-program-info-log } " for the program object if it failed to link. Otherwise, the program object is left on the stack." } ;

HELP: gl-program-info-log
{ $values { "program" "A " { $link gl-program } " object" } }
{ $description "Retrieves the info log for " { $snippet "program" } ", including any errors or warnings generated in linking the program object." } ;

HELP: delete-gl-program
{ $values { "program" "A " { $link gl-program } " object" } }
{ $description "Deletes the program object, invalidating it and releasing any resources allocated for it by the OpenGL implementation. Any attached " { $link gl-shader } "s are also deleted.\n\nIf the shader objects should be preserved, they should each be detached using " { $link detach-gl-program-shader } ". The program object can then be destroyed alone using " { $link delete-gl-program-only } "." } ;

HELP: with-gl-program
{ $values { "program" "A " { $link gl-program } " object" } { "quot" "A quotation" } }
{ $description "Enables " { $snippet "program" } " for all OpenGL calls made in " { $snippet "quot" } ". The fixed-function pipeline is restored at the end of " { $snippet "quot" } "." } ;

ARTICLE: "gl-utilities" "OpenGL utility words"
"In addition to the full OpenGL API, the " { $vocab-link "opengl" } " vocabulary includes some utility words to give OpenGL a more Factor-like feel."
$nl
"Wrappers:"
{ $subsection gl-color }
{ $subsection gl-vertex }
{ $subsection gl-translate }
{ $subsection gen-texture }
{ $subsection bind-texture-unit }
"Combinators:"
{ $subsection do-state }
{ $subsection do-enabled }
{ $subsection do-attribs }
{ $subsection do-matrix }
{ $subsection with-translation }
{ $subsection with-framebuffer }
{ $subsection with-gl-program }
{ $subsection make-dlist }
"Rendering geometric shapes:"
{ $subsection gl-line }
{ $subsection gl-fill-rect }
{ $subsection gl-rect }
{ $subsection gl-fill-poly }
{ $subsection gl-poly }
{ $subsection gl-gradient }
"Compiling, linking, and using GLSL programs:"
{ $subsection gl-shader }
{ $subsection gl-program }
;

ABOUT: "gl-utilities"
