USING: kernel tools.test parser vocabs help.syntax namespaces
eval accessors ;
IN: help.syntax.tests

[
    [ "foobar" ] [
        "IN: help.syntax.tests USE: help.syntax ABOUT: \"foobar\"" eval( -- )
        "help.syntax.tests" lookup-vocab vocab-help
    ] unit-test

    [ { "foobar" } ] [
        "IN: help.syntax.tests USE: help.syntax ABOUT: { \"foobar\" }" eval( -- )
        "help.syntax.tests" lookup-vocab vocab-help
    ] unit-test

    [ ] [ "help.syntax.tests" lookup-vocab f >>help drop ] unit-test
] with-file-vocabs

{ { $description } } [ HELP{ $description } ] unit-test

{ { $description "this and that" } } [
    HELP{ $description this and that }
] unit-test

{ { $description { $snippet "this" } " and that" } } [
    HELP{ $description { $snippet "this" } and that }
] unit-test

{ { $description "this " { $snippet "and" } " that" } } [
    HELP{ $description this { $snippet "and" } that }
] unit-test

{ { $description "this and " { $snippet "that" } } } [
    HELP{ $description this and { $snippet "that" } }
] unit-test

{ { $description "this and " { $snippet "that" } "." } } [
    HELP{ $description this and { $snippet "that" } . }
] unit-test

{ { $description "this, " { $snippet "that" } ", and the other." } } [
    HELP{ $description this, { $snippet "that" } , and the other. }
] unit-test
