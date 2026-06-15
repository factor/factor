USING: destructors help.markup help.syntax kernel math sequences strings ;
IN: pcre2

ARTICLE: "pcre2" "PCRE2 binding"
"The " { $vocab-link "pcre2" } " vocab implements a simple binding for libpcre2, enabling rich regular expression support for Factor applications." $nl
"Precompiling and optimizing a regular expression:"
{ $subsections <pcre2> }
"Once compiled, a " { $link pcre2 } " is a " { $link "destructors" } " disposable and should be released with " { $link dispose } " (or used inside " { $link with-disposal } ")." $nl
"Searching, testing, and splitting:"
{ $subsections
    findall
    matches?
    split
}
"Querying a compiled pattern and the library:"
{ $subsections
    has-option?
    version
}
{ $examples
  { $code
    "USING: pcre2 ; "
    "\"foobar\" \"\\\\w\" findall"
  }
}
{ $notes "Regular expressions are by default utf8 and unicode aware." } ;

HELP: pcre2
{ $class-description "A compiled regular expression. Instances are disposable; release them with " { $link dispose } " or " { $link with-disposal } "." } ;

HELP: <pcre2>
{ $values { "expr" string } { "pcre2" pcre2 } }
{ $description "Creates a precompiled regular expression object. Compilation defaults to utf8 and unicode mode." }
{ $errors "Throws a " { $link pcre2-error } " if the expression cannot be compiled, reporting the libpcre2 error number and the offset within the expression." } ;

HELP: findall
{ $values
  { "subject" string }
  { "obj" "a string, compiled regular expression or a regexp literal" }
  { "matches" sequence }
}
{ $description "Finds all matches of the given regexp in the string. Matches is a sequence of associative arrays where the key is the name of the capturing group, or f to denote the full match." }
{ $examples
  { $code
    "USE: pcre2"
    "\"foobar\" \"(?<ch1>\\\\w)(?<ch2>\\\\w)\" findall ."
    "{"
    "    { { f \"fo\" } { \"ch1\" \"f\" } { \"ch2\" \"o\" } }"
    "    { { f \"ob\" } { \"ch1\" \"o\" } { \"ch2\" \"b\" } }"
    "    { { f \"ar\" } { \"ch1\" \"a\" } { \"ch2\" \"r\" } }"
    "}"
  }
} ;

HELP: matches?
{ $values
  { "subject" string }
  { "obj" "a string, compiled regular expression or a regexp literal" }
  { "?" boolean }
}
{ $description "Tests whether the entire subject is matched by a single occurrence of the regexp." } ;

HELP: split
{ $values
  { "subject" string }
  { "obj" "a string, compiled regular expression or a regexp literal" }
  { "strings" sequence }
}
{ $description "Splits the subject around every match of the regexp, returning the non-empty pieces in between." } ;

HELP: has-option?
{ $values { "pcre2" pcre2 } { "option" integer } { "?" boolean } }
{ $description "Tests whether the given compile-time option (such as " { $snippet "PCRE2_UTF" } ") is set on a compiled pattern." } ;

HELP: version
{ $values { "f" float } }
{ $description "Version number of the libpcre2 library, expressed as a float." } ;

ABOUT: "pcre2"
