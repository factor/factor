USING: help.markup help.syntax ;
IN: unicode

ARTICLE: "unicode" "Unicode"
"Unicode is a set of characters, or " { $emphasis "code points" } " covering what's used in most world writing systems. Any Factor string can hold any of these code points transparently; a factor string is a sequence of Unicode code points. Unicode is accompanied by several standard algorithms for common operations like encoding in files, capitalizing a string, finding the boundaries between words, etc. When a programmer is faced with a string manipulation problem, where the string represents human language, a Unicode algorithm is often much better than the naive one. This is not in terms of efficiency, but rather internationalization. Even English text that remains in ASCII is better served by the Unicode collation algorithm than a naive algorithm. The Unicode algorithms implemented here are:"
{ $vocab-subsection "Case mapping" "unicode.case" }
{ $vocab-subsection "Collation and weak comparison" "unicode.collation" }
{ $vocab-subsection "Character classes" "unicode.categories" }
{ $vocab-subsection "Word and grapheme breaks" "unicode.breaks" }
{ $vocab-subsection "Unicode normalization" "unicode.normalize" }
"The following are mostly for internal use:"
{ $vocab-subsection "Unicode syntax" "unicode.syntax" }
{ $vocab-subsection "Unicode data tables" "unicode.data" }
{ $see-also "io.encodings" } ;

ABOUT: "unicode"
