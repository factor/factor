IN: help.home
USING: help.markup help.syntax ;

ARTICLE: "help.home" "Factor documentation"
{ $heading "Starting points" }
{ $list
  { $link "ui-listener" }
  { $link "handbook" }
  { $link "vocab-index" }
}
{ $heading "Recently visited" }
{ $table
  { "Words" "Articles" "Vocabs" }
  { { $recent recent-words } { $recent recent-articles } { $recent recent-vocabs } }
} print-element
{ $heading "Recent searches" }
{ $recent-searches } ;

ABOUT: "help.home"