IN: opengl.textures
USING: help.markup help.syntax opengl.gl math alien ;

HELP: gen-texture
{ $values { "id" integer } }
{ $description "Wrapper for " { $link glGenTextures } " to handle the common case of generating a single texture ID." } ;

HELP: delete-texture
{ $values { "id" integer } }
{ $description "Wrapper for " { $link glDeleteTextures } " to handle the common case of deleting a single texture ID." } ;

HELP: make-texture
{ $values { "dim" "a pair of integers" } { "pixmap" c-ptr } { "format" "an OpenGL texture format, for example " { $link GL_UNSIGNED_BYTE } } { "type" "an OpenGL texture type, for example " { $link GL_RGBA } } { "id" "an OpenGL texture ID" } }
{ $description "Creates a new OpenGL texture from a pixmap image whose dimensions are equal to " { $snippet "dim" } "." } ;
  