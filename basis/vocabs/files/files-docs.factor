USING: help.markup help.syntax strings ;
IN: vocabs.files

HELP: vocab-files
{ $values { "vocab" "a vocabulary specifier" } { "seq" "a sequence of pathname strings" } }
{ $description "Outputs a sequence of files comprising this vocabulary, or " { $link f } " if the vocabulary does not have a directory on disk." } ;

HELP: vocab-tests
{ $values { "vocab" "a vocabulary specifier" } { "tests" "a sequence of pathname strings" } }
{ $description "Outputs a sequence of pathnames where the unit tests for " { $snippet "vocab" } " are located." } ;

