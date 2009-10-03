USING: help.markup help.syntax ;
IN: values

ARTICLE: "values" "Global values"
"Usually, dynamically-scoped variables subsume global variables and are sufficient for holding global data. But occasionally, for global information that's calculated just once and must be accessed more rapidly than a dynamic variable lookup can provide, it's useful to use the word mechanism instead, and set a word to the appropriate value just once. The " { $vocab-link "values" } " vocabulary implements " { $emphasis "values" } ", which abstract over this concept. To create a new word as a value, use the following syntax:"
{ $subsections POSTPONE: VALUE: }
"To get the value, just call the word. The following words manipulate values:"
{ $subsections
    get-value
    set-value
    POSTPONE: to:
    change-value
} ;

ABOUT: "values"

HELP: VALUE:
{ $syntax "VALUE: word" }
{ $values { "word" "a word to be created" } }
{ $description "Creates a value on the given word, initializing it to hold " { $snippet "f" } ". To get the value, just run the word. To set it, use " { $link POSTPONE: to: } "." }
{ $examples
  { $example
    "USING: values math prettyprint ;"
    "IN: scratchpad"
    "VALUE: x"
    "2 2 + to: x"
    "x ."
    "4"
  }
} ;

HELP: get-value
{ $values { "word" "a value word" } { "value" "the contents" } }
{ $description "Gets a value. This should not normally be used, unless the word is not known until runtime." } ;

HELP: set-value
{ $values { "value" "a new value" } { "word" "a value word" } }
{ $description "Sets a value word." } ;

HELP: to:
{ $syntax "... to: value" }
{ $values { "word" "a value word" } }
{ $description "Sets a value word." }
{ $notes
    "Note that"
    { $code "foo to: value" }
    "is just sugar for"
    { $code "foo \\ value set-value" }
} ;

HELP: change-value
{ $values { "word" "a value word" } { "quot" { $quotation "( oldvalue -- newvalue )" } } }
{ $description "Changes the value using the given quotation." } ;
