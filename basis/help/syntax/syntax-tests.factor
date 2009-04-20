USING: kernel tools.test parser vocabs help.syntax namespaces
eval accessors ;
IN: help.syntax.tests

[
    [ "foobar" ] [
        "IN: help.syntax.tests USE: help.syntax ABOUT: \"foobar\"" eval( -- )
        "help.syntax.tests" vocab vocab-help
    ] unit-test
    
    [ { "foobar" } ] [
        "IN: help.syntax.tests USE: help.syntax ABOUT: { \"foobar\" }" eval( -- )
        "help.syntax.tests" vocab vocab-help
    ] unit-test
    
    [ ] [ "help.syntax.tests" vocab f >>help drop ] unit-test
] with-file-vocabs
