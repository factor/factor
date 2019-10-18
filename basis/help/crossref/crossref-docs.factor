USING: help.topics help.syntax help.markup ;
IN: help.crossref

HELP: article-children
{ $values { "topic" "an article name or a word" } { "seq" "a new sequence" } }
{ $description "Outputs a sequence of all subsections of " { $snippet "topic" } "." } ;

HELP: article-parent
{ $values { "topic" "an article name or a word" } { "parent" "an article name or a word" } }
{ $description "Outputs a help topic which contains " { $snippet "topic" } " as a subsection, or " { $link f } "." } ;

HELP: help-path
{ $values { "topic" "an article name or a word" } { "seq" "a new sequence" } }
{ $description "Outputs a sequence of all help articles which contain " { $snippet "topic" } " as a subsection, traversing all the way up to the root." } ;

HELP: xref-article
{ $values { "topic" "an article name or a word" } }
{ $description "Sets the " { $link article-parent } " of each child of this article." }
$low-level-note ;
