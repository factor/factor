USING: alien help.markup help.syntax io kernel math quotations
opengl.gl assocs vocabs.loader sequences accessors colors words ;
IN: opengl

HELP: gl-color
{ $values { "color" color } }
{ $description "Wrapper for " { $link glColor4d } " taking an instance of " { $link color } "." }
{ $notes "See " { $link "colors" } "." } ;

HELP: gl-error
{ $description "If the most recent OpenGL call resulted in an error, throw a " { $snippet "gl-error" } " instance reporting the error." } ;

HELP: log-gl-error
{ $values { "function" word } }
{ $description "If the most recent OpenGL call resulted in an error, append it to the " { $link gl-error-log } "." }
{ $notes "Don't call this function directly. Call " { $link log-gl-errors } " to annotate every OpenGL function to automatically log errors." } ;

HELP: gl-error-log
{ $var-description "A vector of OpenGL errors logged by " { $link log-gl-errors } ". Each log entry has the following tuple slots:" }
{ $list
    { { $snippet "function" } " is the OpenGL function that raised the error." }
    { { $snippet "error" } " is the OpenGL error code." }
    { { $snippet "timestamp" } " is the time the error was logged." }
}
{ "The error log is emptied using the " { $link clear-gl-error-log } " word." } ;

HELP: clear-gl-error-log
{ $description "Empties the OpenGL error log populated by " { $link log-gl-errors } "." } ;

HELP: throw-gl-errors
{ $description "Annotate every OpenGL function to throw a " { $link gl-error } " if the function results in an error. Use " { $link reset-gl-functions } " to reverse this operation." } ;

HELP: log-gl-errors
{ $description "Annotate every OpenGL function to log using " { $link log-gl-error } " if the function results in an error. Use " { $link reset-gl-functions } " to reverse this operation." } ;

HELP: reset-gl-functions
{ $description "Removes any annotations from all OpenGL functions, such as those applied by " { $link throw-gl-errors } " or " { $link log-gl-errors } "." } ;

{ throw-gl-errors gl-error log-gl-errors log-gl-error clear-gl-error-log reset-gl-functions } related-words

HELP: do-enabled
{ $values { "what" integer } { "quot" quotation } }
{ $description "Wraps a quotation in " { $link glEnable } "/" { $link glDisable } " calls." } ;

HELP: do-matrix
{ $values { "quot" quotation } }
{ $description "Saves and restores the current matrix before and after calling the quotation." } ;

HELP: gl-line
{ $values { "a" "a pair of integers" } { "b" "a pair of integers" } }
{ $description "Draws a line between two points." } ;

HELP: gl-fill-rect
{ $values { "loc" "a pair of integers" } { "dim" "a pair of integers" } }
{ $description "Draws a filled rectangle with the top-left corner at the origin and the given dimensions." } ;

HELP: gl-rect
{ $values { "loc" "a pair of integers" } { "dim" "a pair of integers" } }
{ $description "Draws the outline of a rectangle with the top-left corner at the origin and the given dimensions." } ;

HELP: gen-gl-buffer
{ $values { "id" integer } }
{ $description "Wrapper for " { $link glGenBuffers } " to handle the common case of generating a single buffer ID." } ;

HELP: delete-gl-buffer
{ $values { "id" integer } }
{ $description "Wrapper for " { $link glDeleteBuffers } " to handle the common case of deleting a single buffer ID." } ;

{ gen-gl-buffer delete-gl-buffer } related-words

HELP: bind-texture-unit
{ $values { "id" "The id of a texture object." } { "target" "The texture target (e.g., " { $snippet "GL_TEXTURE_2D" } ")" } { "unit" "The texture unit to bind (e.g., " { $snippet "GL_TEXTURE0" } ")" } }
{ $description "Binds texture " { $snippet "id" } " to texture target " { $snippet "target" } " of texture unit " { $snippet "unit" } ". Equivalent to " { $snippet "unit glActiveTexture target id glBindTexture" } "." } ;

HELP: set-draw-buffers
{ $values { "buffers" "A sequence of buffer words (e.g. " { $snippet "GL_BACK" } ", " { $snippet "GL_COLOR_ATTACHMENT0" } ")"} }
{ $description "Wrapper for " { $link glDrawBuffers } ". Sets up the buffers named in the sequence for simultaneous drawing." } ;

HELP: do-attribs
{ $values { "bits" integer } { "quot" quotation } }
{ $description "Wraps a quotation in " { $link glPushAttrib } "/" { $link glPopAttrib } " calls." } ;

HELP: gen-dlist
{ $values { "id" integer } }
{ $description "Wrapper for " { $link glGenLists } " to handle the common case of generating a single display list ID." } ;

HELP: make-dlist
{ $values { "type" "one of " { $link GL_COMPILE } " or " { $link GL_COMPILE_AND_EXECUTE } } { "quot" quotation } { "id" "an OpenGL texture ID" } }
{ $description "Compiles the results of calling the quotation into a new OpenGL display list." } ;

HELP: gl-translate
{ $values { "point" "a pair of integers" } }
{ $description "Wrapper for " { $link glTranslated } " taking a point object." } ;

HELP: with-translation
{ $values { "loc" "a pair of integers" } { "quot" quotation } }
{ $description "Calls the quotation with a translation by " { $snippet "loc" } " pixels applied to the current " { $link GL_MODELVIEW } " matrix, restoring the matrix when the quotation is done." } ;

ARTICLE: "gl-utilities" "OpenGL utility words"
"The " { $vocab-link "opengl" } " vocabulary implements some utility words to give OpenGL a more Factor-like feel."
$nl
"The " { $vocab-link "opengl.gl" } " and " { $vocab-link "opengl.glu" } " vocabularies have the actual OpenGL bindings."
{ $subsection "opengl-low-level" }
"Error reporting:"
{ $subsection gl-error }
{ $subsection throw-gl-errors }
{ $subsection log-gl-errors }
{ $subsection clear-gl-error-log }
{ $subsection reset-gl-functions }
"Wrappers:"
{ $subsection gl-color }
{ $subsection gl-translate }
{ $subsection bind-texture-unit }
"Combinators:"
{ $subsection do-enabled }
{ $subsection do-attribs }
{ $subsection do-matrix }
{ $subsection with-translation }
{ $subsection make-dlist }
"Rendering geometric shapes:"
{ $subsection gl-line }
{ $subsection gl-fill-rect }
{ $subsection gl-rect }
;

ABOUT: "gl-utilities"
