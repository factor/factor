USING: help.markup help.syntax ;
IN: help.home

ARTICLE: "help.home" "Factor documentation"
{ $content "handbook" }
{ $heading "Recent searches" }
"Use the search field in the top-right of the " { $link "ui-browser" } " window to search for words, vocabularies, and help articles."
{ $recent-searches }
{ $heading "Recently visited pages" }
{ $table
  { "Words" "Articles" "Vocabs" }
  { { $recent recent-words } { $recent recent-articles } { $recent recent-vocabs } }
}
;

ABOUT: "help.home"
