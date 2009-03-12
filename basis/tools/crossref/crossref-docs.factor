USING: help.markup help.syntax words definitions prettyprint ;
IN: tools.crossref

ARTICLE: "tools.crossref" "Cross-referencing tools" 
{ $subsection usage. }
{ $see-also "definitions" "words" "see" } ;

ABOUT: "tools.crossref"

HELP: usage.
{ $values { "word" "a word" } }
{ $description "Prints an list of all callers of a word. This may include the word itself, if it is recursive." }
{ $examples { $code "\\ reverse usage." } } ;

{ usage usage. } related-words
