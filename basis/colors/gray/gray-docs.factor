USING: help.markup help.syntax accessors ;
IN: colors.gray

ARTICLE: "colors.gray" "Grayscale colors"
"The " { $vocab-link "colors.gray" } " vocabulary implements grayscale colors. These colors hold a single value, and respond to " { $link red>> } ", " { $link green>> } ", " { $link blue>> } " with that value. They also have an independent alpha channel, " { $link alpha>> } "."
{ $subsections
    gray
    <gray>
} ;

ABOUT: "colors.gray"
