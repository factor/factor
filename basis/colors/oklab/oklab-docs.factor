USING: help.markup help.syntax ;
IN: colors.oklab

HELP: oklaba
{ $class-description "The class of OKLAB colors with an alpha channel." } ;

ARTICLE: "colors.oklab" "OKLAB colors"
"The " { $vocab-link "colors.oklab" } " vocabulary implements OKLAB colors, specifying luminance (in approximately " { $snippet "[0,100]" } "), red/green, and blue/yellow components, together with an alpha channel."
{ $subsections
    oklaba
    <oklaba>
    >oklaba
}
"For more information, see " { $url "https://en.wikipedia.org/wiki/Oklab_color_space" }
{ $see-also "colors" } ;

ABOUT: "colors.oklab"
