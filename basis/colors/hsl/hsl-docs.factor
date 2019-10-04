USING: help.markup help.syntax ;
IN: colors.hsl

HELP: hsla
{ $class-description "The class of HSL (Hue, Saturation, Lightness) colors with an alpha channel. All slots store values in the interval " { $snippet "[0,1]" } "." } ;

ARTICLE: "colors.hsl" "HSL colors"
"The " { $vocab-link "colors.hsl" } " vocabulary implements colors specified by their hue, saturation, and lightness components, together with an alpha channel."
{ $subsections
    hsla
    <hsla>
    >hsla
}
{ $see-also "colors" } ;

ABOUT: "colors.hsl"
