! Copyright (C) 2008 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: arrays help.markup help.syntax kernel strings words vocabs sequences ;
IN: tools.scaffold

HELP: developer-name
{ $description "Set this symbol to hold your name so that the scaffold tools can generate the correct file header for copyright. Setting this variable in your .factor-boot-rc file is recommended." }
{ $code "USING: namespaces tools.scaffold ;\n\"Stacky Guy\" developer-name set-global" } ;

HELP: help.
{ $values
    { "word" word } }
{ $description "Prints out scaffold help markup for a given word." } ;

HELP: scaffold-docs
{ $values { "obj" object } }
{ $description "Takes a word or vocabulary name and creates a help file with scaffolded help for each word. For vocabulary names, if a file exists this word will not do anything." } ;

HELP: scaffold-undocumented
{ $values
    { "string" string } }
{ $description "Prints scaffolding documentation for undocumented words in a vocabulary except for automatically generated class predicates." } ;

{ scaffold-docs scaffold-undocumented scaffold-examples } related-words

HELP: scaffold-examples
{ $values
    { "word" word }
}
{ $description "Create some examples for a word with a using list that includes vocabularies the word is in and the " { $vocab-link "prettyprint" } " vocabulary. You are then expected to change the header " { $snippet "Example:" } " to something more descriptive." }
{ $examples
    "Create docs for the + word:"
    { $example "USING: math tools.scaffold prettyprint ;"
        "\\ + scaffold-examples"
        "{ $examples
    \"Example:\"
    { $example \"USING: math prettyprint ;\"
        \"\"
        \"\"
    }
    \"Example:\"
    { $example \"USING: math prettyprint ;\"
        \"\"
        \"\"
    }
}"
    }
} ;

HELP: scaffold-core
{ $values
    { "string" string }
}
{ $description "Create a placeholder vocabulary in the core vocabulary root." } ;

HELP: scaffold-basis
{ $values
    { "string" string }
}
{ $description "Create a placeholder vocabulary in the basis vocabulary root." } ;

HELP: scaffold-extra
{ $values
    { "string" string }
}
{ $description "Create a placeholder vocabulary in the extra vocabulary root." } ;

HELP: scaffold-work
{ $values
    { "string" string }
}
{ $description "Create a placeholder vocabulary in the work vocabulary root." } ;

HELP: scaffold-authors
{ $values
    { "vocab" "a vocabulary specifier" }
}
{ $description "Creates an authors.txt file using the value in " { $link developer-name } ". This word only works if no authors.txt file yet exists." } ;

HELP: scaffold-summary
{ $values
    { "vocab" "a vocabulary specifier" } { "summary" string }
}
{ $description "Creates a summary.txt file with the given summary. This word only works if no summary.txt file yet exists." } ;

HELP: scaffold-tags
{ $values
    { "vocab" "a vocabulary specifier" } { "tags" string }
}
{ $description "Creates a tags.txt file with the given tags. This word only works if no tags.txt file yet exists." } ;

HELP: scaffold-tests
{ $values
    { "vocab" "a vocabulary specifier" }
}
{ $description "Takes an existing vocabulary and creates an empty tests file. This word only works if no tests file yet exists." } ;

HELP: scaffold-vocab-in
{ $values
    { "vocab-root" "a vocabulary root string" } { "string" string } }
{ $description "Creates a directory in the given root for a new vocabulary and adds a main .factor file and an authors.txt file." } ;

HELP: scaffold-vocab
{ $values { "string" string } }
{ $description "Searches parent vocabularies for an appropriate root to create a new vocabulary and adds a main .factor file and an authors.txt file." } ;

HELP: scaffold-emacs
{ $description "Touches the .emacs file in your home directory and provides a clickable link to open it in an editor." } ;

HELP: scaffold-factor-boot-rc
{ $description "Touches the .factor-boot-rc file in your home directory and provides a clickable link to open it in an editor." } ;

HELP: scaffold-factor-rc
{ $description "Touches the .factor-rc file in your home directory and provides a clickable link to open it in an editor." } ;

HELP: scaffold-factor-roots
{ $description "Touches the .factor-roots file in your home directory and provides a clickable link to open it in an editor." } ;

HELP: scaffold-rc
{ $values
    { "path" "a pathname string" }
}
{ $description "Touches the given path in your home directory and provides a clickable link to open it in an editor." } ;

HELP: using
{ $description "Stores the vocabularies that are pulled into the documentation file from looking up the stack effect types." } ;

HELP: make-unit-test
{ $values
    { "answer" string } { "code" string }
    { "str" string }
}
{ $description "Takes a code snippet and an answer string and returns a unit-test code snippet for use with " { $vocab-link "tools.test" } " vocabulary. The answer string should represent an array of values left on the stack by the code snippet." }
{ $examples
    { $example
        "USING: io tools.scaffold ;"
        "\"{ 2 2 3 }\" \"3 2 dup rot\" make-unit-test write"
        "{ 2 2 3 } [\n    3 2 dup rot\n] unit-test"
    }
}
{ $see-also read-unit-test } ;

HELP: run-string
{ $values
    { "string" string }
    { "datastack" array }
}
{ $description "Parses and executes the string on an empty datastack, returning the resulting datastack as an array." }
{ $see-also read-unit-test } ;

HELP: read-unit-test
{ $values
    { "str/f" { $maybe string } }
}
{ $description "Consumes a code snippet from input stream, runs it, and returns a unit-test code snippet for use with " { $vocab-link "tools.test" } " vocabulary. If no characters were read before the empty line returns " { $link f } " instead. On the interactive listener input is consumed until an empty line." }
{ $see-also run-string make-unit-test scaffold-unit-tests } ;

HELP: read-unit-tests
{ $values
    { "str" string }
}
{ $description "Reads code snippets by the means of " { $link read-unit-test } " until two empty lines are input. Returns them separated with two newlines." } ;

HELP: scaffold-unit-tests
{ $values
    { "vocab" "a vocabulary specifier" }
}
{ $description "Takes an existing vocabulary and creates an empty test file if one isn't present yet. Reads code snippets separated by empty lines from input stream until a double empty line. After each snippet prints a unit test based on the snippet to output stream and appends it to the test file." { $nl }
"This word enables quick creation of unit tests by recording outputs of code snippets and getting immediate feedback to fix any discrepancies as they occur." }
{ $see-also read-unit-test } ;

ARTICLE: "tools.scaffold" "Scaffold tool"
"Scaffold setup:"
{ $subsections developer-name }
"Generate new vocabs:"
{ $subsections scaffold-vocab scaffold-core scaffold-basis scaffold-extra scaffold-work }
"Generate help scaffolding:"
{ $subsections
    scaffold-docs
    scaffold-undocumented
    scaffold-examples
    scaffold-n-examples
    help.
}
"Types that are unrecognized by the scaffold generator will be of type " { $link object } ". The developer should change these to strings that describe the stack effect names instead." $nl
"Scaffolding a configuration file:"
{ $subsections
    scaffold-rc
    scaffold-factor-boot-rc
    scaffold-factor-rc
    scaffold-factor-roots
    scaffold-emacs
}
"Scaffolding a test file:"
{ $subsections
    scaffold-tests
    scaffold-unit-tests
    read-unit-test
}
;

ABOUT: "tools.scaffold"
