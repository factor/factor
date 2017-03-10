IN: colors.constants
USING: help.markup help.syntax strings colors ;

HELP: named-color
{ $values { "name" string } { "color" color } }
{ $description "Outputs a named color from the color database." }
{ $notes "In most cases, " { $link POSTPONE: COLOR: } " should be used instead." }
{ $errors "Throws an error if the color is not listed in " { $snippet "rgb.txt" } ", " { $snippet "factor-colors.txt" } " or " { $snippet "solarized-colors.txt" } "." } ;

HELP: named-colors
{ $values { "keys" "a sequence of strings" } }
{ $description "Outputs a sequence of all colors in the " { $snippet "rgb.txt" } " database." } ;

HELP: COLOR:
{ $syntax "COLOR: name" }
{ $description "Parses as a " { $link color } " object with the given name." }
{ $errors "Throws an error if the color is not listed in " { $snippet "rgb.txt" } "." }
{ $examples
  { $code
    "USING: colors.constants io.styles ;"
    "\"Hello!\" { { foreground COLOR: cyan } } format nl"
  }
} ;

ARTICLE: "colors.constants" "Standard color database"
"The " { $vocab-link "colors.constants" } " vocabulary bundles the X11 " { $snippet "rgb.txt" } " database and Factor's " { $snippet "factor-colors.txt" } " theme database to provide words for looking up color values by name."
{ $subsections
    named-color
    named-colors
    POSTPONE: COLOR:
} ;

ABOUT: "colors.constants"
