USING: help.syntax help.markup ui.freetype strings kernel
alien opengl quotations ui.render io.styles ;

HELP: freetype
{ $values { "alien" alien } }
{ $description "Outputs a native handle used by the FreeType library, initializing FreeType first if necessary." } ;

HELP: open-fonts
{ $var-description "Global variable. Hashtable mapping font descriptors to " { $link font } " instances." } ;

{ font open-fonts open-font char-width string-width text-dim draw-string draw-text } related-words

HELP: init-freetype
{ $description "Initializes the FreeType library." }
{ $notes "Do not call this word if you are using the UI." } ;

USE: ui.freetype

HELP: font
{ $class-description "A font which has been loaded by FreeType. Font instances have the following slots:"
    { $list
        { { $link font-ascent } ", " { $link font-descent } ", " { $link font-height } " - metrics." }
        { { $link font-handle } " - alien pointer to an " { $snippet "FT_Face" } "." }
        { { $link font-widths } " - sequence of character widths. Use " { $link char-width } " and " { $link string-width } " to compute string widths instead of reading this sequence directly." }
    }
} ;

HELP: close-freetype
{ $description "Closes the FreeType library." }
{ $notes "Do not call this word if you are using the UI." } ;

HELP: open-face
{ $values { "font" string } { "style" "one of " { $link plain } ", " { $link bold } ", " { $link italic } " or " { $link bold-italic } } { "face" "alien pointer to an " { $snippet "FT_Face" } } }
{ $description "Loads a TrueType font with the requested logical font name and style." }
{ $notes "This is a low-level word. Call " { $link open-font } " instead." } ;

HELP: render-glyph
{ $values  { "font" font } { "char" "a non-negative integer" } { "bitmap" alien } }
{ $description "Renders a character and outputs a pointer to the bitmap." } ;

HELP: <char-sprite>
{ $values { "font" font } { "char" "a non-negative integer" } { "sprite" sprite } }
{ $description "Renders a character to an OpenGL texture and records a display list which draws a quad with this texture. This word allocates native resources which must be freed by " { $link free-sprites } "." } ;

HELP: (draw-string)
{ $values { "open-font" font } { "sprites" "a vector of " { $link sprite } " instances" } { "string" string } { "loc" "a pair of integers" } }
{ $description "Draws a line of text." }
{ $notes "This is a low-level word, UI code should use " { $link draw-string } " or " { $link draw-text } " instead." }
{ $side-effects "sprites" } ;

HELP: run-char-widths
{ $values { "open-font" font } { "string" string } { "widths" "a sequence of integers" } }
{ $description "Outputs a sequence of x co-ordinates of the midpoint of each character in the string." }
{ $notes "This word is used to convert x offsets to document locations, for example when the user moves the caret by clicking the mouse." } ;
