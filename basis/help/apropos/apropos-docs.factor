USING: help.apropos help.markup help.syntax help.tips strings ;
IN: help.apropos+docs

HELP: apropos
{ $values { "str" string } }
{ $description "Lists all words, vocabularies and help articles whose name contains a subsequence equal to " { $snippet "str" } ". Results are ranked using a simple distance algorithm." } ;

TIP: "Use " { $link apropos } " to search for words, vocabularies and help articles." ;
