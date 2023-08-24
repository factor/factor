USING: help.markup help.syntax ;
IN: colors.cmyk

HELP: cmyka
{ $class-description "The class of CMYK (Cyan, Magenta, Yellow, Black) colors with an alpha channel. All slots store values in the interval " { $snippet "[0,1]" } "." } ;

ARTICLE: "colors.cmyk" "CMYK colors"
"The " { $vocab-link "colors.cmyk" } " vocabulary implements colors specified by their cyan, magenta, yellow, and black components, together with an alpha channel."
{ $subsections
    cmyka
    <cmyka>
    >cmyka
}
{ $see-also "colors" } ;

ABOUT: "colors.cmyk"
