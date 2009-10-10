USING: help.syntax help.markup kernel prettyprint sequences strings words math ;
IN: ctags.etags

ARTICLE: "etags" "Etags file"
{ $emphasis "Etags" } " generates a index file of every factor word in etags format as supported by emacs and other editors. More information can be found at " { $url "http://en.wikipedia.org/wiki/Ctags#Etags_2" } "."
{ $subsections
    etags
    etags-write
    etag-strings
    etag-header
}

HELP: etags ( path -- )
{ $values { "path" string } }
{ $description "Generates a index file in etags format and stores in " { $snippet "path" } "." }
{ $examples
  { $unchecked-example
    "USING: ctags.etags ;"
    "\"ETAGS\" etags"
    ""
  }
} ;

HELP: etags-write ( alist path -- )
{ $values { "alist" sequence }
          { "path" string } }
{ $description "Stores a " { $snippet "alist" } " in " { $snippet "path" } ". " { $snippet "alist" } " must be an association list with etags format: its key must be a resource path and its value a vector, containing pairs of words and lines" }
{ $examples
  { $unchecked-example
    "USING: kernel etags.ctags ;"
    "{ { \"resource:extra/unix/unix.factor\" V{ { dup2 91 } } } } \"ETAGS\" etags-write"
    ""
  }
} ;

HELP: etag-strings ( alist -- seq )
{ $values { "alist" sequence }
          { "seq" sequence } }
{ $description "Converts an " { $snippet "alist" } " with etag format (a path as key and a vector containing word/line pairs) in a " { $snippet "seq" } " of strings." } ;

ABOUT: "etags" ;