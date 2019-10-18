USING: help.markup help.syntax literals sequences strings ;
IN: vocabs.files

HELP: vocab-tests-path
{ $values { "vocab" "a vocabulary specifier" } { "path" "pathname string to test file" } }
{ $description "Outputs a pathname where the unit test file for " { $snippet "vocab" } " is located. Outputs " { $link f } " if the vocabulary does not have a directory on disk." } ;

HELP: vocab-tests-file
{ $values { "vocab" "a vocabulary specifier" } { "path/f" "pathname string to test file" } }
{ $description "Outputs a pathname where the unit test file is located, or " { $link f } " if the file does not exist." } ;

HELP: vocab-tests-dir
{ $values { "vocab" "a vocabulary specifier" } { "paths" "a sequence of pathname strings" } }
{ $description "Outputs a sequence of pathnames for the tests in the test directory." } ;

HELP: vocab-files
{ $values { "vocab" "a vocabulary specifier" } { "seq" "a sequence of pathname strings" } }
{ $description "Outputs a sequence of files comprising this vocabulary, or " { $link f } " if the vocabulary does not have a directory on disk." }
{ $examples
  { $example
    "USING: prettyprint vocabs.files ; "
    "\"alien.libraries\" vocab-files ."
    $[
        {
            "{"
            "    \"resource:basis/alien/libraries/libraries.factor\""
            "    \"resource:basis/alien/libraries/libraries-docs.factor\""
            "    \"resource:basis/alien/libraries/libraries-tests.factor\""
            "}"
        } "\n" join
    ]
  }
} ;

HELP: vocab-tests
{ $values { "vocab" "a vocabulary specifier" } { "tests" "a sequence of pathname strings" } }
{ $description "Outputs a sequence of pathnames where the unit tests for " { $snippet "vocab" } " are located." }
{ $examples
  { $example
    "USING: prettyprint sorting vocabs.files ; "
    "\"xml\" vocab-tests natural-sort ."
    $[
        {
            "{"
            "    \"resource:basis/xml/tests/cdata.factor\""
            "    \"resource:basis/xml/tests/encodings.factor\""
            "    \"resource:basis/xml/tests/funny-dtd.factor\""
            "    \"resource:basis/xml/tests/soap.factor\""
            "    \"resource:basis/xml/tests/state-parser-tests.factor\""
            "    \"resource:basis/xml/tests/templating.factor\""
            "    \"resource:basis/xml/tests/test.factor\""
            "    \"resource:basis/xml/tests/xmltest.factor\""
            "    \"resource:basis/xml/tests/xmode-dtd.factor\""
            "}"
        } "\n" join
    ]
  }
} ;
