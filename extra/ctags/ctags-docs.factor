USING: help.syntax help.markup kernel prettyprint sequences strings ;
IN: ctags

ARTICLE: "ctags" "Ctags file"
{ $emphasis "ctags" } " generates a index file of every factor word in ctags format as supported by vi and other editors. More information can be found at " { $url "http://en.wikipedia.org/wiki/Ctags" } "."
{ $subsection ctags }
{ $subsection ctags-write }
{ $subsection ctag-strings }
{ $subsection ctag } ;

HELP: ctags ( path -- )
{ $values { "path" "a pathname string" } }
{ $description "Generates a index file in ctags format and stores in " { $snippet "path" } "." }
{ $examples
  { $unchecked-example
    "USING: ctags ;"
    "\"tags\" ctags"
    ""
  }
} ;

HELP: ctags-write ( seq path -- )
{ $values { "alist" "an association list" }
          { "path" "a pathname string" } }
{ $description "Stores a " { $snippet "alist" } " in " { $snippet "path" } ". " { $snippet "alist" } " must be an association list with ctags format: key must be a valid word and value a sequence whose first element is a resource name and second element is a line number" }
{ $examples
  { $unchecked-example
    "USING: kernel ctags ;"
    "{ { if  { \"resource:extra/unix/unix.factor\" 91 } } } \"tags\" ctags-write"
    ""
  }
}
{ $notes
  { $snippet "tags" } " file will contain a single line: if\\t/path/to/factor/extra/unix/unix.factor\\t91" } ;

HELP: ctag-strings ( alist -- seq )
{ $values { "alist" "an association list" }
          { "seq" sequence } }
{ $description "Converts an " { $snippet "alist" } " with ctag format (a word as key and a sequence whose first element is a resource name and a second element is a line number as value) in a " { $snippet "seq" } " of ctag strings." }
{ $examples
  { $unchecked-example
    "USING: kernel ctags prettyprint ;"
    "{ { if  { \"resource:extra/unix/unix.factor\" 91 } } } ctag-strings ."
    "{ \"if\\t/path/to/factor/extra/unix/unix.factor\\t91\" }"
  }
} ;

HELP: ctag ( seq -- str )
{ $values { "seq" sequence }
          { "str" string } }
{ $description "Outputs a string " { $snippet "str" } " in ctag format for sequence with two elements, first one must be a valid word and second one a sequence whose first element is a resource name and second element is a line number" }
{ $examples
  { $unchecked-example
    "USING: kernel ctags prettyprint ;"
    "{ if  { \"resource:extra/unix/unix.factor\" 91 } } ctag ."
    "\"if\\t/path/to/factor/extra/unix/unix.factor\\t91\""
  }
} ;

ABOUT: "ctags"