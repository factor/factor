USING: help.markup help.syntax ;
IN: colors.ryb

HELP: ryba
{ $class-description "The class of RYB (Red, Yellow, Blue) colors with an alpha channel. All slots store values in the interval " { $snippet "[0,1]" } "." } ;

ARTICLE: "colors.ryb" "RYB colors"
"The " { $vocab-link "colors.ryb" } " vocabulary implements colors specified by their red, yellow, and blue components, together with an alpha channel."
{ $subsections
    ryba
    <ryba>
    >ryba
}
{ $see-also "colors" } ;

ABOUT: "colors.ryb"
