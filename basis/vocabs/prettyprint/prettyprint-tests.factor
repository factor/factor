USING: vocabs.prettyprint vocabs.prettyprint.private tools.test
io.streams.string eval ;
IN: vocabs.prettyprint.tests

: manifest-test-1 ( -- string )
    "USING: kernel namespaces vocabs.parser vocabs.prettyprint ;

    << manifest get pprint-manifest >>" ;

{
"USING: kernel namespaces vocabs.parser vocabs.prettyprint ;"
}
[ [ manifest-test-1 eval( -- ) ] with-string-writer ] unit-test

: manifest-test-2 ( -- string )
    "USING: kernel namespaces vocabs.parser vocabs.prettyprint ;
    IN: vocabs.prettyprint.tests

    << manifest get pprint-manifest >>" ;

{
"USING: kernel namespaces vocabs.parser vocabs.prettyprint ;
IN: vocabs.prettyprint.tests"
}
[ [ manifest-test-2 eval( -- ) ] with-string-writer ] unit-test

: manifest-test-3 ( -- string )
    "USING: kernel namespaces vocabs.parser vocabs.prettyprint ;
    FROM: math => + - ;
    QUALIFIED: system
    QUALIFIED-WITH: assocs a
    EXCLUDE: parser => run-file ;
    IN: vocabs.prettyprint.tests

    << manifest get pprint-manifest >>" ;

{
"USING: kernel namespaces vocabs.parser vocabs.prettyprint ;
FROM: math => + - ;
QUALIFIED: system
QUALIFIED-WITH: assocs a
EXCLUDE: parser => run-file ;
IN: vocabs.prettyprint.tests"
}
[ [ manifest-test-3 eval( -- ) ] with-string-writer ] unit-test

{
"USING: alien.c-types alien.syntax byte-arrays io
io.encodings.binary io.encodings.string io.encodings.utf8
io.streams.byte-array kernel sequences system system-info unix ;"
} [
    [
        {
            "alien.c-types"
            "alien.syntax"
            "byte-arrays"
            "io"
            "io.encodings.binary"
            "io.encodings.string"
            "io.encodings.utf8"
            "io.streams.byte-array"
            "kernel"
            "sequences"
            "system"
            "system-info"
            "unix"
        } pprint-using
    ] with-string-writer
] unit-test
