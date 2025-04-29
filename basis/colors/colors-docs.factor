USING: accessors help.markup help.syntax strings ;
IN: colors

HELP: color
{ $class-description "The class of colors. Implementations include " { $link rgba } ", " { $vocab-link "colors.gray" } " and " { $vocab-link "colors.hsv" } "." } ;

HELP: rgba
{ $class-description "The class of colors with red, green, blue and alpha channel components. The slots store color components, which are real numbers in the range 0 to 1, inclusive." } ;

HELP: >rgba
{ $values { "color" color } { "rgba" rgba } }
{ $contract "Converts a color to an RGBA color." } ;

HELP: named-color
{ $values { "name" string } { "color" color } }
{ $description "Outputs a named color from the color database." }
{ $notes "In most cases, " { $link POSTPONE: COLOR: } " should be used instead." }
{ $errors "Throws an error if the color is not listed in " { $snippet "rgb.txt" } ", " { $snippet "factor-colors.txt" } " or " { $snippet "solarized-colors.txt" } "." } ;

HELP: named-colors
{ $values { "keys" "a sequence of strings" } }
{ $description "Outputs a sequence of all colors in the " { $snippet "rgb.txt" } " database." } ;

HELP: parse-color
{ $values { "str" string } { "color" color } }
{ $description "Parses a string as a named value or as a hexadecimal value." }
{ $examples
    { $example
        "USING: colors prettyprint ;"
        "COLOR: sky-blue ."
        "COLOR: sky-blue"
    }
    { $example
        "USING: colors prettyprint ;"
        "COLOR: #336699 ."
        "COLOR: #336699"
    }
} ;

HELP: COLOR:
{ $syntax "COLOR: string" }
{ $description "Parses as a " { $link color } " object using " { $link parse-color } "." }
{ $errors "Throws an error if the color is not able to be parsed." }
{ $examples
  { $code
    "USING: colors io.styles ;"
    "\"Hello!\" { { foreground COLOR: cyan } } format nl"
  }
} ;

ARTICLE: "colors.protocol" "Color protocol"
"Abstract superclass for colors:"
{ $subsections color }
"All color objects are required to implement a method on the " { $link >rgba } " generic word."
$nl
"Optionally, they can provide methods on the accessors " { $link red>> } ", " { $link green>> } ", " { $link blue>> } " and " { $link alpha>> } ", either by defining slots with the appropriate names, or with methods which calculate the color component values. The accessors should return color components which are real numbers in the range between 0 and 1."
$nl
"Overriding the accessors is purely an optimization, since the default implementations call " { $link >rgba } " and then extract the appropriate component of the result." ;

ARTICLE: "colors.constants" "Standard color database"
"The " { $vocab-link "colors" } " vocabulary bundles the X11 " { $snippet "rgb.txt" } " database and Factor's " { $snippet "factor-colors.txt" } " theme database to provide words for looking up color values by name."
{ $subsections
    named-color
    named-colors
    parse-color
    POSTPONE: COLOR:
} ;

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
"Color implementations:"
{ $vocab-subsections
    { "CIE 1931 XYZ colors" "colors.xyz" }
    { "CIE 1931 xyY colors" "colors.xyy" }
    { "CIE 1976 LAB colors" "colors.lab" }
    { "CIE 1976 LUV colors" "colors.luv" }
    { "CMYK colors" "colors.cmyk" }
    { "Grayscale colors" "colors.gray" }
    { "HSL colors" "colors.hsl" }
    { "HSV colors" "colors.hsv" }
    { "HWB colors" "colors.hwb" }
    { "RYB colors" "colors.ryb" }
    { "YIQ colors" "colors.yiq" }
    { "YUV colors" "colors.yuv" }
    { "OKLAB colors" "colors.oklab" }
    { "OKLCH colors" "colors.oklch" }
} ;

ABOUT: "colors"
