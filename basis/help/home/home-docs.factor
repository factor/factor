USING: help.markup help.syntax help.topics literals
sequences.generalizations ;
IN: help.home

ARTICLE: "help.home" "Factor documentation"
$[ "handbook" lookup-article article-content 6 firstn ]
{ $heading "Searches" }
"Use the search field in the top-right of the " { $link "ui-browser" } " window to search for words, vocabularies, and help articles."
{ $recent-searches }
{ $heading "Recently visited pages" }
{ $table
  { "Words" "Articles" "Vocabs" }
  { { $recent recent-words } { $recent recent-articles } { $recent recent-vocabs } }
}
;

ABOUT: "help.home"
