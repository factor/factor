USING: byte-arrays help.syntax help.markup kernel math.order
strings unicode ;
IN: unicode.collation

ARTICLE: "unicode.collation" "Collation and weak comparison"
"The " { $vocab-link "unicode.collation" } " vocabulary implements the Unicode Collation Algorithm. The Unicode Collation Algorithm (UTS #10) forms a reasonable way to sort strings when accounting for all of the characters in Unicode. It is far preferred over code point order when sorting for human consumption, in user interfaces. At the moment, only the default Unicode collation element table (DUCET) is used, but a more accurate collation would take locale into account. The following words are useful for collation directly:"
{ $subsections
    sort-strings
    collation-key/nfd
    string<=>
}
"Predicates for weak equality testing:"
{ $subsections
    primary=
    secondary=
    tertiary=
    quaternary=
} ;

ABOUT: "unicode.collation"

HELP: sort-strings
{ $values { "strings" "a sequence of strings" } { "sorted" "the strings in lexicographical order" } }
{ $description "This word takes a sequence of strings and sorts them according to the Unicode Collation Algorithm with the default collation order described in the DUCET. It uses code point order as a tie-breaker." } ;

HELP: collation-key/nfd
{ $values { "string" string } { "key" byte-array } { "nfd" object } }
{ $description "This takes a string and gives a representation of the collation key, which can be compared with " { $link <=> } ". The representation is according to the DUCET." } ;

HELP: string<=>
{ $values { "str1" string } { "str2" string } { "<=>" "one of +lt+, +gt+ or +eq+" } }
{ $description "This word takes two strings and compares them using the UCA with the DUCET, using code point order as a tie-breaker." } ;

HELP: primary=
{ $values { "str1" string } { "str2" string } { "?" boolean } }
{ $description "This checks whether the first level of collation key is identical. This is the least specific kind of equality test. In Latin script, it can be understood as ignoring case, punctuation, whitespace and accent marks." } ;

HELP: secondary=
{ $values { "str1" string } { "str2" string } { "?" boolean } }
{ $description "This checks whether the first two levels of collation key are equal. For Latin script, this means accent marks are significant again, and it is otherwise similar to " { $link primary= } "." } ;

HELP: tertiary=
{ $values { "str1" string } { "str2" string } { "?" boolean } }
{ $description "This checks if the first three levels of collation key are equal. For Latin-based scripts, it can be understood as testing for what " { $link secondary= } " tests for, but case is significant." } ;

HELP: quaternary=
{ $values { "str1" string } { "str2" string } { "?" boolean } }
{ $description "This checks if the first four levels of collation key are equal. This is similar to " { $link tertiary= } " but it makes punctuation significant again, while still leaving out things like null bytes and Hebrew vowel marks, which mean absolutely nothing in collation." } ;
