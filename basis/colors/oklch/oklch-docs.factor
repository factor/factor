USING: help.markup help.syntax ;
IN: colors.oklch

HELP: oklcha
{ $class-description "The class of OKLCH colors with an alpha channel." } ;

ARTICLE: "colors.oklch" "OKLCH colors"
"The " { $vocab-link "colors.oklch" } " vocabulary implements OKLCH colors, specifying luminance (in approximately " { $snippet "[0,100]" } "), polar chroma, and hue components, together with an alpha channel."
{ $subsections
    oklcha
    <oklcha>
    >oklcha
}
"For more information, see " { $url "https://en.wikipedia.org/wiki/Oklab_color_space" }
{ $see-also "colors" } ;

ABOUT: "colors.oklch"
