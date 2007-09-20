IN: temporary
USING: tools.test parser vocabs help.syntax namespaces ;

[
    file-vocabs

    [ "foobar" ] [
        "IN: temporary USE: help.syntax ABOUT: \"foobar\"" eval
        "temporary" vocab vocab-help
    ] unit-test
    
    [ { "foobar" } ] [
        "IN: temporary USE: help.syntax ABOUT: { \"foobar\" }" eval
        "temporary" vocab vocab-help
    ] unit-test
    
    SYMBOL: xyz
    
    [ xyz ] [
        "IN: temporary USE: help.syntax ABOUT: xyz" eval
        "temporary" vocab vocab-help
    ] unit-test
] with-scope
