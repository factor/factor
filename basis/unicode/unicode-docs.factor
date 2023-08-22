USING: help.markup help.syntax strings ;
IN: unicode

ARTICLE: "unicode" "Unicode support"
"The " { $vocab-link "unicode" } " vocabulary and its sub-vocabularies implement support for the Unicode 14.0 character set."
$nl
"The Unicode character set contains most of the world's writing systems. Unicode is intended as a replacement for, and is a superset of, such legacy character sets as ASCII, Latin1, MacRoman, and so on. Unicode characters are called " { $emphasis "code points" } "; Factor's " { $link "strings" } " are sequences of code points."
$nl
"The Unicode character set is accompanied by several standard algorithms for common operations like encoding text in files, capitalizing a string, finding the boundaries between words, and so on."
$nl
"The Unicode algorithms implemented by the " { $vocab-link "unicode" } " vocabulary are:"
{ $vocab-subsections
    { "Case mapping" "unicode.case" }
    { "Collation and weak comparison" "unicode.collation" }
    { "Character classes" "unicode.categories" }
    { "Word and grapheme breaks" "unicode.breaks" }
    { "Unicode normalization" "unicode.normalize" }
}
"The following are mostly for internal use:"
{ $vocab-subsections
    { "Unicode category syntax" "unicode.categories" }
    { "Unicode data tables" "unicode.data" }
}
{ $see-also "ascii" "io.encodings" } ;

ABOUT: "unicode"
