! Copyright (C) 2017 Pi.
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax strings ;
IN: unicode.control-pictures

HELP: control-pictures
{ $values
    { "string" string }
}
{ $description "Transforms C0 control characters into their corresponding Control Picture block codepoints." } ;

ARTICLE: "unicode.control-pictures" "Control Pictures"
"The " { $vocab-link "unicode.control-pictures" } " vocabulary provides a utility word " { $link control-pictures } " for transforming characters in the nonprintable " { $url "http://www.unicode.org/charts/PDF/U0000.pdf" "ASCII C0 block" } " to their representations in the " { $url "http://www.unicode.org/charts/PDF/U2400.pdf" "Control Pictures" } " block. It has no effect on any other characters."
;

ABOUT: "unicode.control-pictures"
