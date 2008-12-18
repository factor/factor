USING: help.markup help.syntax parser ;
IN: vocabs.parser

ARTICLE: "vocabulary-search-shadow" "Shadowing word names"
"If adding a vocabulary to the search path results in a word in another vocabulary becoming inaccessible due to the new vocabulary defining a word with the same name, we say that the old word has been " { $emphasis "shadowed" } "."
$nl
"Here is an example where shadowing occurs:"
{ $code
    "IN: foe"
    "USING: sequences io ;"
    ""
    ": append"
    "    \"foe::append calls sequences:append\" print  append ;"
    ""
    "IN: fee"
    ""
    ": append"
    "    \"fee::append calls fee:append\" print  append ;"
    ""
    "IN: fox"
    "USE: foe"
    ""
    ": append"
    "    \"fox::append calls foe:append\" print  append ;"
    ""
    "\"1234\" \"5678\" append print"
    ""
    "USE: fox"
    "\"1234\" \"5678\" append print"
}
"When placed in a source file and run, the above code produces the following output:"
{ $code
    "foe:append calls sequences:append"
    "12345678"
    "fee:append calls foe:append"
    "foe:append calls sequences:append"
    "12345678"
} ;

ARTICLE: "vocabulary-search-errors"  "Word lookup errors"
"If the parser cannot not find a word in the current vocabulary search path, it attempts to look for the word in all loaded vocabularies."
$nl
"If " { $link auto-use? } " mode is off, a restartable error is thrown with a restart for each vocabulary in question, together with a restart which defers the word in the current vocabulary, as if " { $link POSTPONE: DEFER: } " was used."
$nl
"If " { $link auto-use? } " mode is on and only one vocabulary has a word with this name, the vocabulary is added to the search path and parsing continues."
$nl
"If any restarts were invoked, or if " { $link auto-use? } " is on, the parser will print the correct " { $link POSTPONE: USING: } " after parsing completes. This form can be copy and pasted back into the source file."
{ $subsection auto-use? } ;

ARTICLE: "vocabulary-search" "Vocabulary search path"
"When the parser reads a token, it attempts to look up a word named by that token. The lookup is performed by searching each vocabulary in the search path, in order."
$nl
"For a source file the vocabulary search path starts off with one vocabulary:"
{ $code "syntax" }
"The " { $vocab-link "syntax" } " vocabulary consists of a set of parsing words for reading Factor data and defining new words."
$nl
"In the listener, the " { $vocab-link "scratchpad" } " is the default vocabulary for new word definitions. However, when loading source files, there is no default vocabulary. Defining words before declaring a vocabulary with " { $link POSTPONE: IN: } " results in an error."
$nl
"At the interactive listener, the default search path contains many more vocabularies. Details on the default search path and parser invocation are found in " { $link "parser" } "."
$nl
"Three parsing words deal with the vocabulary search path:"
{ $subsection POSTPONE: IN: }
{ $subsection POSTPONE: USE: }
{ $subsection POSTPONE: USING: }
"There are some additional parsing words give more control over word lookup than is offered by " { $link POSTPONE: USE: } " and " { $link POSTPONE: USING: } ":"
{ $subsection POSTPONE: QUALIFIED: }
{ $subsection POSTPONE: QUALIFIED-WITH: }
{ $subsection POSTPONE: FROM: }
{ $subsection POSTPONE: EXCLUDE: }
{ $subsection POSTPONE: RENAME: }
"These words are useful when there is no way to avoid using two vocabularies with identical word names in the same source file."
$nl
"Private words can be defined; note that this is just a convention and they can be called from other vocabularies anyway:"
{ $subsection POSTPONE: <PRIVATE }
{ $subsection POSTPONE: PRIVATE> }
{ $subsection "vocabulary-search-errors" }
{ $subsection "vocabulary-search-shadow" }
{ $see-also "words" } ;

ABOUT: "vocabulary-search"
