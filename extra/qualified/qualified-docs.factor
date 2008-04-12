USING: help.markup help.syntax ;
IN: qualified

HELP: QUALIFIED:
{ $syntax "QUALIFIED: vocab" }
{ $description "Similar to " { $link POSTPONE: USE: } " but loads vocabulary with prefix." }
{ $examples { $code
    "QUALIFIED: math\n1 2 math:+ ! ==> 3" } } ;

HELP: QUALIFIED-WITH:
{ $syntax "QUALIFIED-WITH: vocab prefix" }
{ $description "Works like " { $link POSTPONE: QUALIFIED: } " but uses the specified prefix." }
{ $examples { $code
    "QUALIFIED-WITH: math m\n1 2 m:+ ! ==> 3" } } ;

HELP: FROM:
{ $syntax "FROM: vocab => words ... ;" }
<<<<<<< HEAD:extra/qualified/qualified-docs.factor
{ $description "Imports " { $snippet "words" } " from " { $snippet "vocab" } "." }
=======
{ $description "Imports the specified words from vocab." }
>>>>>>> 04e914c... qualified: fixing docs a bit.:extra/qualified/qualified-docs.factor
{ $examples { $code
    "FROM: math.parser => bin> hex> ; ! imports only bin> and hex>" } } ;

HELP: EXCLUDE:
{ $syntax "EXCLUDE: vocab => words ... ;" }
<<<<<<< HEAD:extra/qualified/qualified-docs.factor
{ $description "Imports everything from " { $snippet "vocab" } " excluding " { $snippet "words" } "." }
=======
{ $description "Imports everything from vocab excluding the specified words" }
>>>>>>> 04e914c... qualified: fixing docs a bit.:extra/qualified/qualified-docs.factor
{ $examples { $code
    "EXCLUDE: math.parser => bin> hex> ; ! imports everythin but bin> and hex>" } } ;

HELP: RENAME:
{ $syntax "RENAME: word vocab => newname " }
<<<<<<< HEAD:extra/qualified/qualified-docs.factor
{ $description "Imports " { $snippet "word" } " from " { $snippet "vocab" } ", but renamed to " { $snippet "newname" } "." }
=======
{ $description "Imports word from vocab, but renamed to newname." }
>>>>>>> 04e914c... qualified: fixing docs a bit.:extra/qualified/qualified-docs.factor
{ $examples { $code
    "RENAME: + math => -"
    "2 3 - ! => 5" } } ;

