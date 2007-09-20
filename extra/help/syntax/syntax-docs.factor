USING: help.markup help.syntax vocabs ;

HELP: HELP:
{ $syntax "HELP: word content... ;" }
{ $values { "word" "a word" } { "content" "markup elements" } }
{ $description "Defines documentation for a word." }
{ $examples
    { $code
        ": foo 2 + ;"
        "HELP: foo"
        "{ $values { \"m\" \"an integer\" } { \"n\" \"an integer\" } }"
        "{ $description \"Increments a value by 2.\" } ;"
        "\\ foo help"
    }
} ;

HELP: ARTICLE:
{ $syntax "ARTICLE: topic title content... ;" }
{ $values { "topic" "an object" } { "title" "a string" } { "content" "markup elements" } }
{ $description "Defines a help article. String topic names are reserved for core documentation. Contributed modules should name articles by arrays, where the first element of an array identifies the module; for example, " { $snippet "{ \"httpd\" \"intro\" }" } "." }
{ $examples
    { $code
        "ARTICLE: \"example\" \"An example article\""
        "\"Hello world.\" ;"
    }
} ;

HELP: ABOUT:
{ $syntax "MAIN: article" }
{ $values { "article" "a help article" } }
{ $description "Defines the main documentation article for the current vocabulary." } ;

HELP: vocab-help
{ $values { "vocab" "a vocabulary specifier" } { "help" "a help article" } }
{ $description "Outputs the main help article for a vocabulary. The main help article can be set with " { $link POSTPONE: ABOUT:  } "." } ;
