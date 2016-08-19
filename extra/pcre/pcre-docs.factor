USING: help.markup help.syntax math sequences strings ;
IN: pcre

ARTICLE: "pcre" "PCRE binding"
"The " { $vocab-link "pcre" } " vocab implements a simple binding for libpcre, enabling rich regular expression support for Factor applications." $nl
"Precompiling and optimizing a regular expression:"
{ $subsections <compiled-pcre> }
{ $examples
  { $code
    "USING: pcre ; "
    "\"foobar\" \"\\\\w\" findall"
  }
}
{ $notes "Regular expressions are by default utf8 and unicode aware." } ;

HELP: <compiled-pcre>
{ $values { "expr" string } { "compiled-pcre" compiled-pcre } }
{ $description "Creates a precompiled regular expression object." } ;

HELP: findall
{ $values
  { "subject" string }
  { "obj" "a string, compiled regular expression or a regexp literal" }
  { "matches" sequence }
}
{ $description "Finds all matches of the given regexp in the string. Matches is sequence of associative array where the key is the name of the capturing group, or f to denote the full match." }
{ $examples
  { $code
    "USE: pcre"
    "\"foobar\" \"(?<ch1>\\\\w)(?<ch2>\\\\w)\" findall ."
    "{"
    "    { { f \"fo\" } { \"ch1\" \"f\" } { \"ch2\" \"o\" } }"
    "    { { f \"ob\" } { \"ch1\" \"o\" } { \"ch2\" \"b\" } }"
    "    { { f \"ar\" } { \"ch1\" \"a\" } { \"ch2\" \"r\" } }"
    "}"
  }
} ;

HELP: version
{ $values { "f" float } }
{ $description "Version number of the PCRE library, expressed as a float." } ;

ABOUT: "pcre"
