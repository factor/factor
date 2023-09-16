IN: opengl.textures
USING: help.markup help.syntax opengl.gl opengl.textures.private math alien images ;

HELP: gen-texture
{ $values { "id" integer } }
{ $description "Wrapper for " { $link glGenTextures } " to handle the common case of generating a single texture ID." } ;

HELP: create-texture
{ $values { "id" integer } }
{ $description "Wrapper for " { $link glCreateTextures } " to handle the common case of generating a single DSA texture ID." } ;

HELP: delete-texture
{ $values { "id" integer } }
{ $description "Wrapper for " { $link glDeleteTextures } " to handle the common case of deleting a single texture ID." } ;

HELP: make-texture
{ $values { "image" image } { "id" "an OpenGL texture ID" } }
{ $description "Creates a new OpenGL texture from a pixmap image whose dimensions are equal to " { $snippet "dim" } "." } ;
