IN: help.home
USING: help.markup help.syntax ;

ARTICLE: "help.home" "Factor documentation"
{ $heading "Getting started" }
{ $subsections
    "cookbook"
    "first-program"
}
{ $heading "User interface" }
{ $subsections
  "listener"
  "ui-tools"
}
{ $heading "Reference" }
{ $subsections
  "handbook"
  "vocab-index"
  "article-index"
  "primitive-index"
  "error-index"
  "class-index"
}
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
