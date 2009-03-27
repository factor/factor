IN: help.apropos
USING: help.markup help.syntax strings help.tips ;

HELP: apropos
{ $values { "str" string } }
{ $description "Lists all words, vocabularies and help articles whose name contains a subsequence equal to " { $snippet "str" } ". Results are ranked using a simple distance algorithm." } ;

TIP: "Use " { $link apropos } " to search for words, vocabularies and help articles." ;