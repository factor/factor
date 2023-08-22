IN: ui.text
USING: help.markup help.syntax kernel ui.text.private strings math fonts images ;

HELP: flush-layout-cache
{ $description "Flushes the cache of pre-rendered layouts." } ;

HELP: string-width
{ $values { "font" font } { "string" string } { "w" "a positive integer" } }
{ $contract "Outputs the width of a string." }
{ $notes "This is a low-level word; use " { $link text-width } " instead." } ;

HELP: text-width
{ $values { "font" font } { "text" "a string or sequence of strings" } { "w" "a positive integer" } }
{ $description "Outputs the width of a piece of text." } ;

HELP: string-height
{ $values { "font" font } { "string" string } { "h" "a positive integer" } }
{ $contract "Outputs the height of a string." }
{ $notes "This is a low-level word; use " { $link text-height } " instead." } ;

HELP: text-height
{ $values { "font" font } { "text" "a string or sequence of strings" } { "h" "a positive integer" } }
{ $description "Outputs the height of a piece of text." } ;

HELP: string-dim
{ $values { "font" font } { "string" string } { "dim" "a pair of integers" } }
{ $contract "Outputs the dimensions of a string." }
{ $notes "This is a low-level word; use " { $link text-dim } " instead." } ;

HELP: text-dim
{ $values { "font" font } { "text" "a string or sequence of strings" } { "dim" "a pair of integers" } }
{ $description "Outputs the dimensions of a piece of text, which is either a single-line string or an array of lines." } ;

HELP: draw-string
{ $values { "font" font } { "string" string } }
{ $contract "Draws a line of text." } ;

HELP: draw-text
{ $values { "font" font } { "text" "a string or an array of strings" } }
{ $description "Draws a piece of text." } ;

HELP: x>offset
{ $values { "x" real } { "font" font } { "string" string } { "n" integer } }
{ $contract "Outputs the string index closest to the given x coordinate." } ;

HELP: offset>x
{ $values { "n" integer } { "font" font } { "string" string } { "x" real } }
{ $contract "Outputs the x coordinate of the character at the given index." } ;

HELP: line-metrics
{ $values { "font" font } { "string" string } { "metrics" line-metrics } }
{ $contract "Outputs a " { $link metrics } " object with text measurements." } ;

HELP: string>image
{ $values { "font" font } { "string" string } { "image" image } { "loc" "a pair of real numbers" } }
{ $description "Renders a line of text into an image." } ;

ARTICLE: "text-rendering" "Rendering text"
"The " { $vocab-link "ui.text" } " vocabulary provides a cross-platform interface to the operating system's native font rendering engine. Currently, it uses Core Text on Mac OS X, Uniscribe on Windows and Pango on X11."
{ $subsections "fonts" }
"Measuring text:"
{ $subsections
    text-dim
    text-width
    text-height
    line-metrics
}
"Converting screen locations to string offsets, and vice versa:"
{ $subsections
    x>offset
    offset>x
}
"Rendering text:"
{ $subsections draw-text string>image }
"Low-level text protocol for UI backends:"
{ $subsections
    string-width
    string-height
    string-dim
    draw-string
} ;

ABOUT: "text-rendering"
