USING: help.markup help.syntax ;
IN: colors.hcl

HELP: hcla
{ $class-description "The class of HCL (Hue, Chroma, Luminance) colors with an alpha channel. All slots store values in the interval " { $snippet "[0,1]" } "." } ;

ARTICLE: "colors.hcl" "HCL colors"
"The " { $vocab-link "colors.hcl" } " vocabulary implements colors specified by their hue, chroma, and luminance components, together with an alpha channel."
{ $subsections
    hcla
    <hcla>
    >hcla
}
"The HCL color space is simply the polar representation of the CIELUV color space. For more information."
{ $see-also "colors" "colors.luv" } ;

ABOUT: "colors.hcl"
