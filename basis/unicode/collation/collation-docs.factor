USING: help.syntax help.markup strings byte-arrays ;
IN: unicode.collation

ARTICLE: "unicode.collation" "Collation and weak comparison"
"The " { $vocab-link "unicode.collation" "unicode.collation" } " vocabulary implements the Unicode Collation Algorithm. The Unicode Collation Algorithm (UTS #10) forms a reasonable way to sort strings when accouting for all of the characters in Unicode. It is far preferred over code point order when sorting for human consumption, in user interfaces. At the moment, only the default Unicode collation element table (DUCET) is used, but a more accurate collation would take locale into account. The following words are defined:"
{ $subsection sort-strings }
{ $subsection collation-key }
{ $subsection string<=> }
{ $subsection primary= }
{ $subsection secondary= }
{ $subsection tertiary= }
{ $subsection quaternary= } ;

ABOUT: "unicode.collation"

HELP: sort-strings
{ $values { "strings" "a sequence of strings" } { "sorted" "the strings in DUCET order" } }
{ $description "This word takes a sequence of strings and sorts them according to the UCA, using code point order as a tie-breaker." } ;

HELP: collation-key
{ $values { "string" string } { "key" byte-array } }
{ $description "This takes a string and gives a representation of the collation key, which can be compared with <=>" } ;

HELP: string<=>
{ $values { "str1" string } { "str2" string } { "<=>" "one of +lt+, +gt+ or +eq+" } }
{ $description "This word takes two strings and compares them using the UCA with the DUCET, using code point order as a tie-breaker." } ;

HELP: primary=
{ $values { "str1" string } { "str2" string } { "?" "t or f" } }
{ $description "This checks whether the first level of collation is identical. This is the least specific kind of equality test. In Latin script, it can be understood as ignoring case, punctuation and accent marks." } ;

HELP: secondary=
{ $values { "str1" string } { "str2" string } { "?" "t or f" } }
{ $description "This checks whether the first two levels of collation are equal. For Latin script, this means accent marks are significant again, and it is otherwise similar to primary=." } ;

HELP: tertiary=
{ $values { "str1" string } { "str2" string } { "?" "t or f" } }
{ $description "Along the same lines as secondary=, but case is significant." } ;

HELP: quaternary=
{ $values { "str1" string } { "str2" string } { "?" "t or f" } }
{ $description "This is similar to tertiary= but it makes punctuation significant again, while still leaving out things like null bytes and Hebrew vowel marks, which mean absolutely nothing in collation." } ;
