USING: help.markup help.syntax ;
IN: values

ARTICLE: "values" "Global values"
"Usually, dynamically scoped variables are sufficient for holding data which is not literal. But occasionally, for global information that's calculated just once, it's useful to use the word mechanism instead, and set the word to the appropriate value just once. Values abstract over this concept. To create a new word as a value, use the following syntax:"
{ $subsection POSTPONE: VALUE: }
"To get the value, just call the word. The following words manipulate values:"
{ $subsection get-value }
{ $subsection set-value }
{ $subsection change-value } ;

HELP: VALUE:
{ $syntax "VALUE: word" }
{ $values { "word" "a word to be created" } }
{ $description "Creates a value on the given word, initializing it to hold " { $code f } ". To get the value, just run the word. To set it, use " { $link set-value } "." } ;

HELP: get-value
{ $values { "word" "a value word" } { "value" "the contents" } }
{ $description "Gets a value. This should not normally be used, unless the word is not known until runtime." } ;

HELP: set-value
{ $values { "value" "a new value" } { "word" "a value word" } }
{ $description "Sets the value word." } ;

HELP: change-value
{ $values { "word" "a value word" } { "quot" "a quotation ( oldvalue -- newvalue )" } }
{ $description "Changes the value using the given quotation." } ;
