USING: help.markup help.syntax strings ;
IN: vocabs.files

HELP: vocab-tests-file
{ $values { "vocab" "a vocabulary specifier" } { "path" "pathname string to test file" } }
{ $description "Outputs a pathname where the unit test file is located." } ;

HELP: vocab-tests-dir
{ $values { "vocab" "a vocabulary specifier" } { "paths" "a sequence of pathname strings" } }
{ $description "Outputs a sequence of pathnames for the tests in the test directory." } ;

HELP: vocab-files
{ $values { "vocab" "a vocabulary specifier" } { "seq" "a sequence of pathname strings" } }
{ $description "Outputs a sequence of files comprising this vocabulary, or " { $link f } " if the vocabulary does not have a directory on disk." } ;

HELP: vocab-tests
{ $values { "vocab" "a vocabulary specifier" } { "tests" "a sequence of pathname strings" } }
{ $description "Outputs a sequence of pathnames where the unit tests for " { $snippet "vocab" } " are located." } ;

