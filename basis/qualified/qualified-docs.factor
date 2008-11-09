USING: help.markup help.syntax ;
IN: qualified

HELP: QUALIFIED:
{ $syntax "QUALIFIED: vocab" }
{ $description "Similar to " { $link POSTPONE: USE: } " but loads vocabulary with prefix." }
{ $examples { $code
    "QUALIFIED: math\n1 2 math:+ ! ==> 3" } } ;

HELP: QUALIFIED-WITH:
{ $syntax "QUALIFIED-WITH: vocab word-prefix" }
{ $description "Works like " { $link POSTPONE: QUALIFIED: } " but uses " { $snippet "word-prefix" } " as prefix." }
{ $examples { $code
    "QUALIFIED-WITH: math m\n1 2 m:+ ! ==> 3" } } ;

HELP: FROM:
{ $syntax "FROM: vocab => words ... ;" }
{ $description "Imports " { $snippet "words" } " from " { $snippet "vocab" } "." }
{ $examples { $code
    "FROM: math.parser => bin> hex> ; ! imports only bin> and hex>" } } ;

HELP: EXCLUDE:
{ $syntax "EXCLUDE: vocab => words ... ;" }
{ $description "Imports everything from " { $snippet "vocab" } " excluding " { $snippet "words" } "." }
{ $examples { $code
    "EXCLUDE: math.parser => bin> hex> ; ! imports everything but bin> and hex>" } } ;

HELP: RENAME:
{ $syntax "RENAME: word vocab => newname " }
{ $description "Imports " { $snippet "word" } " from " { $snippet "vocab" } ", but renamed to " { $snippet "newname" } "." }
{ $examples { $code
    "RENAME: + math => -"
    "2 3 - ! => 5" } } ;

ARTICLE: "qualified" "Qualified word lookup"
"The " { $vocab-link "qualified" } " vocabulary provides a handful of parsing words which give more control over word lookup than is offered by " { $link POSTPONE: USE: } " and " { $link POSTPONE: USING: } "."
$nl
"These words are useful when there is no way to avoid using two vocabularies with identical word names in the same source file."
{ $subsection POSTPONE: QUALIFIED: }
{ $subsection POSTPONE: QUALIFIED-WITH: }
{ $subsection POSTPONE: FROM: }
{ $subsection POSTPONE: EXCLUDE: }
{ $subsection POSTPONE: RENAME: } ;

ABOUT: "qualified"
