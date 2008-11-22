USING: help.markup help.syntax io strings ;
IN: tools.vocabs.browser

ARTICLE: "vocab-tags" "Vocabulary tags"
{ $all-tags } ;

ARTICLE: "vocab-authors" "Vocabulary authors"
{ $all-authors } ;

ARTICLE: "vocab-index" "Vocabulary index"
{ $subsection "vocab-tags" }
{ $subsection "vocab-authors" }
{ $describe-vocab "" } ;
