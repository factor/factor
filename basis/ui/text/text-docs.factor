IN: ui.text
USING: help.markup help.syntax kernel ui.text.private strings math ;

HELP: open-font
{ $values { "font" "a font specifier" } { "open-font" object } }
{ $contract "Loads a font if it has not already been loaded, otherwise outputs the existing font." }
{ $errors "Throws an error if the font does not exist." }
{ $notes "This word should not be called by user code. All high-level text rendering words will call " { $link open-font } " automatically." } ;

HELP: string-width
{ $values { "open-font" "a value output by " { $link open-font } } { "string" string } { "w" "a positive integer" } }
{ $contract "Outputs the width of a string." }
{ $notes "This is a low-level word; use " { $link text-width } " instead." } ;

HELP: text-width
{ $values { "font" "a font specifier" } { "text" "a string or sequence of strings" } { "w" "a positive integer" } }
{ $description "Outputs the width of a piece of text." } ;

HELP: string-height
{ $values { "open-font" "a value output by " { $link open-font } } { "string" string } { "h" "a positive integer" } }
{ $contract "Outputs the height of a string." }
{ $notes "This is a low-level word; use " { $link text-height } " instead." } ;

HELP: text-height
{ $values { "font" "a font specifier" } { "text" "a string or sequence of strings" } { "h" "a positive integer" } }
{ $description "Outputs the height of a piece of text." } ;

HELP: string-dim
{ $values { "open-font" "a value output by " { $link open-font } } { "string" string } { "dim" "a pair of integers" } }
{ $contract "Outputs the dimensions of a string." }
{ $notes "This is a low-level word; use " { $link text-dim } " instead." } ;

HELP: text-dim
{ $values { "font" "a font specifier" } { "text" "a string or sequence of strings" } { "dim" "a pair of integers" } }
{ $description "Outputs the dimensions of a piece of text, which is either a single-line string or an array of lines." } ;

HELP: draw-string
{ $values { "font" "a font specifier" } { "string" string } { "loc" "a pair of integers" } }
{ $contract "Draws a line of text." } ;

HELP: draw-text
{ $values { "font" "a font specifier" } { "text" "a string or an array of strings" } { "loc" "a pair of integers" } }
{ $description "Draws a piece of text." } ;

HELP: x>offset
{ $values { "x" real } { "font" "a font specifier" } { "string" string } { "n" integer } }
{ $contract "Outputs the string index closest to the given x co-ordinate." } ;

HELP: offset>x
{ $values { "n" integer } { "font" "a font specifier" } { "string" string } { "x" real } }
{ $contract "Outputs the x co-ordinate of the character at the given index." } ;

ARTICLE: "text-rendering" "Rendering text"
"The " { $vocab-link "ui.text" } " vocabulary provides a cross-platform interface to the operating system's native font rendering engine. Currently, it uses Core Text on Mac OS X and FreeType on Windows and X11."
$nl
"Measuring text:"
{ $subsection text-dim }
{ $subsection text-width }
{ $subsection text-height }
"Converting screen locations to string offsets, and vice versa:"
{ $subsection x>offset }
{ $subsection offset>x }
"Rendering text:"
{ $subsection draw-text }
"Low-level text protocol for UI backends:"
{ $subsection open-font }
{ $subsection string-width }
{ $subsection string-height }
{ $subsection string-dim }
{ $subsection draw-string } ;

ABOUT: "text-rendering"