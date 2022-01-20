USING: help.markup help.syntax strings ;
IN: ctags.etags

ARTICLE: "etags" "Etags file"
{ $emphasis "Etags" } " generates a index file of every factor word in etags format as supported by emacs and other editors. More information can be found at " { $url "http://en.wikipedia.org/wiki/Ctags#Etags_2" } "."
{ $subsections
    etags
    write-etags
} ;

HELP: write-etags
{ $values { "path" string } }
{ $description "Generates a index file in etags format and stores in " { $snippet "path" } "." }
{ $examples
  { $unchecked-example
    "USING: ctags.etags ;"
    "\"ETAGS\" etags"
    ""
  }
} ;

ABOUT: "etags"
