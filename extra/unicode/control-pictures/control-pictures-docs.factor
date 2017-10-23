! Copyright (C) 2017 Pi.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs hashtables help.markup help.stylesheet help.syntax
help.topics io.styles kernel namespaces present sequences
strings urls ;
IN: unicode.control-pictures

: $url-to ( children -- )
    first2 >url [
        dup present href associate url-style get assoc-union
        [ write-object ] with-style
    ] ($span) ;

HELP: control-pictures
{ $values
    { "string" string }
}
{ $description "Transforms C0 control characters into their corresponding Control Picture block codepoints." } ;

ARTICLE: "unicode.control-pictures" "Control Pictures"
"The " { $vocab-link "unicode.control-pictures" } " vocabulary provides a utility word " { $link control-pictures } " for transforming characters in the nonprintable " { $url-to "ASCII C0 block" "http://www.unicode.org/charts/PDF/U0000.pdf" } " to their representations in the " { $url-to "Control Pictures" "http://www.unicode.org/charts/PDF/U2400.pdf" } " block. It has no effect on any other characters."
;

ABOUT: "unicode.control-pictures"
