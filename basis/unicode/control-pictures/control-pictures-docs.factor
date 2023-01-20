! Copyright (C) 2022 Alex Maestas.
! See https://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax strings ;
IN: unicode.control-pictures

HELP: control-pictures
{ $values
    { "string" string }
}
{ $description "Transforms C0 control characters, excepting spaces, into their corresponding Control Picture block codepoints." } ;

HELP: control-pictures*
{ $values
    { "string" string }
}
{ $description "Transforms C0 control characters, including spaces, into their corresponding Control Picture block codepoints." } ;


ARTICLE: "unicode.control-pictures" "Control Pictures"
"The " { $vocab-link "unicode.control-pictures" } " vocabulary provides utility words for transforming characters in the nonprintable " { $url "https://www.unicode.org/charts/PDF/U0000.pdf" "ASCII C0 block" } " to their representations in the " { $url "https://www.unicode.org/charts/PDF/U2400.pdf" "Control Pictures" } " block. It has no effect on any other characters."
$nl
"Two words are provided - " { $link control-pictures } " transforms control characters, excepting spaces, to their picture form. The variant " { $link control-pictures* } " also transforms spaces."
;

ABOUT: "unicode.control-pictures"
