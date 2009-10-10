USING: vocabs.prettyprint tools.test io.streams.string eval ;
IN: vocabs.prettyprint.tests

: manifest-test-1 ( -- string )
    """USING: kernel namespaces vocabs.parser vocabs.prettyprint ;

    << manifest get pprint-manifest >>""" ;

[
"""USING: kernel namespaces vocabs.parser vocabs.prettyprint ;"""
]
[ [ manifest-test-1 eval( -- ) ] with-string-writer ] unit-test

: manifest-test-2 ( -- string )
    """USING: kernel namespaces vocabs.parser vocabs.prettyprint ;
    IN: vocabs.prettyprint.tests

    << manifest get pprint-manifest >>""" ;

[
"""USING: kernel namespaces vocabs.parser vocabs.prettyprint ;
IN: vocabs.prettyprint.tests"""
]
[ [ manifest-test-2 eval( -- ) ] with-string-writer ] unit-test

: manifest-test-3 ( -- string )
    """USING: kernel namespaces vocabs.parser vocabs.prettyprint ;
    FROM: math => + - ;
    QUALIFIED: system
    QUALIFIED-WITH: assocs a
    EXCLUDE: parser => run-file ;
    IN: vocabs.prettyprint.tests

    << manifest get pprint-manifest >>""" ;

[
"""USING: kernel namespaces vocabs.parser vocabs.prettyprint ;
FROM: math => + - ;
QUALIFIED: system
QUALIFIED-WITH: assocs a
EXCLUDE: parser => run-file ;
IN: vocabs.prettyprint.tests"""
]
[ [ manifest-test-3 eval( -- ) ] with-string-writer ] unit-test
