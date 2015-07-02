IN: colors.hsv
USING: help.markup help.syntax ;

HELP: hsva
{ $class-description "The class of HSV (Hue, Saturation, Value) colors with an alpha channel. The " { $slot "hue" } " slot stores a value in the interval " { $snippet "[0,360]" } " and the remaining slots store values in the interval " { $snippet "[0,1]" } "." } ;

ARTICLE: "colors.hsv" "HSV colors"
"The " { $vocab-link "colors.hsv" } " vocabulary implements colors specified by their hue, saturation, and value, together with an alpha channel."
{ $subsections
    hsva
    <hsva>
}
{ $see-also "colors" } ;

ABOUT: "colors.hsv"
