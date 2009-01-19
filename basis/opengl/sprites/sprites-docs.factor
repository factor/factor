IN: opengl.sprites
USING: help.markup help.syntax ;

HELP: sprite
{ $class-description "A sprite is an OpenGL texture together with a display list which renders a textured quad. Sprites are used to draw text in the UI. Sprites have the following slots:"
    { $list
        { { $snippet "dlist" } " - an OpenGL display list ID" }
        { { $snippet "texture" } " - an OpenGL texture ID" }
        { { $snippet "loc" } " - top-left corner of the sprite" }
        { { $snippet "dim" } " - dimensions of the sprite" }
        { { $snippet "dim2" } " - dimensions of the sprite, rounded up to the nearest powers of two" }
    }
} ;

HELP: free-sprites
{ $values { "sprites" "a sequence of " { $link sprite } " instances" } }
{ $description "Deallocates native resources associated toa  sequence of sprites." } ;

