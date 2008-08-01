USING: help.markup help.syntax words definitions ;
IN: tools.crossref

ARTICLE: "tools.crossref" "Cross-referencing tools" 
{ $subsection usage. }
{ $subsection apropos }
{ $see-also "definitions" "words" } ;

ABOUT: "tools.crossref"

HELP: usage.
{ $values { "word" "a word" } }
{ $description "Prints an list of all callers of a word. This may include the word itself, if it is recursive." }
{ $examples { $code "\\ reverse usage." } } ;

{ usage usage. } related-words

HELP: apropos
{ $values { "str" "a string" } }
{ $description "Lists all words whose name contains a subsequence equal to " { $snippet "str" } ". Results are ranked using a simple distance algorithm." } ;
