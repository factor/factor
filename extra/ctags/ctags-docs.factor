USING: help.markup help.syntax vocabs ;
IN: ctags

ARTICLE: "ctags" "Ctags file"
{ $emphasis "ctags" } " generates a index file of every factor word in ctags format as supported by vi and other editors. More information can be found at " { $url "http://en.wikipedia.org/wiki/Ctags" } "."
{ $subsections
    ctags
    write-ctags
} ;

HELP: write-ctags
{ $values { "path" "a pathname string" } }
{ $description "Generates a index file in ctags format and stores in " { $snippet "path" } "." }
{ $examples
  { $unchecked-example
    "USING: ctags ;"
    "\"tags\" write-ctags"
    ""
  }
} ;

HELP: ctags
{ $values { "ctags" "alist" } }
{ $description "Make a sequence of ctags from " { $link all-words } ", sorted by word name." } ;

ABOUT: "ctags"
