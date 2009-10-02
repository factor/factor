IN: colors
USING: accessors help.markup help.syntax ;

HELP: color
{ $class-description "The class of colors. Implementations include " { $link rgba } ", " { $vocab-link "colors.gray" } " and " { $vocab-link "colors.hsv" } "." } ;

HELP: rgba
{ $class-description "The class of colors with red, green, blue and alpha channel components. The slots store color components, which are real numbers in the range 0 to 1, inclusive." } ;

HELP: >rgba
{ $values { "color" color } { "rgba" rgba } }
{ $contract "Converts a color to an RGBA color." } ;

ARTICLE: "colors.protocol" "Color protocol"
"Abstract superclass for colors:"
{ $subsections color }
"All color objects must are required to implement a method on the " { $link >rgba } " generic word."
$nl
"Optionally, they can provide methods on the accessors " { $link red>> } ", " { $link green>> } ", " { $link blue>> } " and " { $link alpha>> } ", either by defining slots with the appropriate names, or with methods which calculate the color component values. The accessors should return color components which are real numbers in the range between 0 and 1."
$nl
"Overriding the accessors is purely an optimization, since the default implementations call " { $link >rgba } " and then extract the appropriate component of the result." ;

ARTICLE: "colors" "Colors"
"The " { $vocab-link "colors" } " vocabulary defines a protocol for colors, with a concrete implementation for RGBA colors. This vocabulary is used by " { $vocab-link "io.styles" } ", " { $vocab-link "ui" } " and other vocabularies, but it is independent of them."
$nl
"RGBA colors with floating point components in the range " { $snippet "[0,1]" } ":"
{ $subsections
    rgba
    <rgba>
}
"Converting a color to RGBA:"
{ $subsections >rgba }
"Extracting RGBA components of colors:"
{ $subsections >rgba-components }
"Further topics:"
{ $subsections
    "colors.protocol"
    "colors.constants"
}
{ $vocab-subsection "Grayscale colors" "colors.gray" }
{ $vocab-subsection "HSV colors" "colors.hsv" } ;

ABOUT: "colors"