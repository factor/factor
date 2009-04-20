IN: help.home
USING: help.markup help.syntax ;

ARTICLE: "help.home" "Factor documentation"
"If this is your first time with Factor, you can start by writing " { $link "first-program" } "."
{ $heading "Reference" }
{ $list
  { $link "handbook" }
  { $link "vocab-index" }
  { $link "ui-tools" }
  { $link "ui-listener" }
}
{ $heading "Recently visited" }
{ $table
  { "Words" "Articles" "Vocabs" }
  { { $recent recent-words } { $recent recent-articles } { $recent recent-vocabs } }
}
"The browser, completion popups and other tools use a common set of " { $link "definitions.icons" } "."
{ $heading "Recent searches" }
{ $recent-searches }
"Use the search field in the top-right of the " { $link "ui-browser" } " window to search for words, vocabularies and help articles." ;

ABOUT: "help.home"