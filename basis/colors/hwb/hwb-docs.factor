USING: help.markup help.syntax ;
IN: colors.hwb

HELP: hwba
{ $class-description "The class of HWB (Hue, Whiteness, Blackness) colors with an alpha channel. All slots store values in the interval " { $snippet "[0,1]" } "." } ;

ARTICLE: "colors.hwb" "HWB colors"
"The " { $vocab-link "colors.hwb" } " vocabulary implements colors specified by their hue, whiteness and blackness components, together with an alpha channel."
{ $subsections
    hwba
    <hwba>
    >hwba
}
{ $see-also "colors" } ;

ABOUT: "colors.hwb"
