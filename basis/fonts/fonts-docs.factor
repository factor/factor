! Copyright (C) 2009 Slava Pestov
! See https://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax kernel colors strings ;
IN: fonts

HELP: <font>
{ $values { "name" string } { "font" font } }
{ $description "Creates a new font with the given " { $snippet "name" } " and " { $link default-font-size } ", " { $link default-font-foreground } ", and " { $link default-font-background } "." } ;

HELP: font
{ $class-description "The class of fonts." } ;

HELP: font-with-background
{ $values
    { "font" font } { "color" color }
    { "font'" font }
}
{ $description "Creates a new font equal to the given font, except with a different " { $slot "background" } " slot." } ;

HELP: font-with-foreground
{ $values
    { "font" font } { "color" color }
    { "font'" font }
}
{ $description "Creates a new font equal to the given font, except with a different " { $slot "foreground" } " slot." } ;

ARTICLE: "fonts" "Fonts"
"The " { $vocab-link "fonts" } " vocabulary implements a data type for fonts that other vocabularies, for example " { $link "ui" } ", can use. A font combines a font name, size, style, and color information into a single object."
{ $subsections
    font
    <font>
}
"Modifying fonts:"
{ $subsections
    font-with-foreground
    font-with-background
}
"Useful constants:"
{ $subsections
    monospace-font
    sans-serif-font
    serif-font
}
"A data type for font metrics. The " { $vocab-link "fonts" } " vocabulary does not provide any means of computing font metrics, it simply defines a common data type that other vocabularies, such as " { $vocab-link "ui.text" } " may use:"
{ $subsections metrics } ;

ABOUT: "fonts"
