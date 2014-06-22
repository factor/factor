USING: help.markup help.syntax ;
IN: colors.lab

HELP: laba
{ $class-description "The class of CIE 1976 LAB colors with an alpha channel." } ;

ARTICLE: "colors.lab" "CIE 1976 LAB colors"
"The " { $vocab-link "colors.lab" } " vocabulary implements CIE 1976 LAB colors, specifying luminance (in approximately " { $snippet "[0,100]" } "), red/green, and blue/yellow components, together with an alpha channel."
{ $subsections
    laba
    <laba>
    >laba
}
{ $see-also "colors" } ;
