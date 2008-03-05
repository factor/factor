IN: help.syntax.tests
USING: tools.test parser vocabs help.syntax namespaces ;

[
    [ "foobar" ] [
        "IN: help.syntax.tests USE: help.syntax ABOUT: \"foobar\"" eval
        "help.syntax.tests" vocab vocab-help
    ] unit-test
    
    [ { "foobar" } ] [
        "IN: help.syntax.tests USE: help.syntax ABOUT: { \"foobar\" }" eval
        "help.syntax.tests" vocab vocab-help
    ] unit-test
    
    SYMBOL: xyz
    
    [ xyz ] [
        "IN: help.syntax.tests USE: help.syntax ABOUT: xyz" eval
        "help.syntax.tests" vocab vocab-help
    ] unit-test
] with-file-vocabs
