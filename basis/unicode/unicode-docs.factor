USING: help.markup help.syntax strings ;
IN: unicode

ARTICLE: "unicode" "Unicode support"
"The " { $vocab-link "unicode" } " vocabulary and its sub-vocabularies implement support for the Unicode 5.2 character set."
$nl
"The Unicode character set contains most of the world's writing systems. Unicode is intended as a replacement for, and is a superset of, such legacy character sets as ASCII, Latin1, MacRoman, and so on. Unicode characters are called " { $emphasis "code points" } "; Factor's " { $link "strings" } " are sequences of code points."
$nl
"The Unicode character set is accompanied by several standard algorithms for common operations like encoding text in files, capitalizing a string, finding the boundaries between words, and so on."
$nl
"The Unicode algorithms implemented by the " { $vocab-link "unicode" } " vocabulary are:"
{ $vocab-subsection "Case mapping" "unicode.case" }
{ $vocab-subsection "Collation and weak comparison" "unicode.collation" }
{ $vocab-subsection "Character classes" "unicode.categories" }
{ $vocab-subsection "Word and grapheme breaks" "unicode.breaks" }
{ $vocab-subsection "Unicode normalization" "unicode.normalize" }
"The following are mostly for internal use:"
{ $vocab-subsection "Unicode category syntax" "unicode.categories" }
{ $vocab-subsection "Unicode data tables" "unicode.data" }
{ $see-also "ascii" "io.encodings" } ;

ABOUT: "unicode"
