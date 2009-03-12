IN: tools.apropos
USING: help.markup help.syntax strings ;

HELP: apropos
{ $values { "str" string } }
{ $description "Lists all words, vocabularies and help articles whose name contains a subsequence equal to " { $snippet "str" } ". Results are ranked using a simple distance algorithm." } ;
