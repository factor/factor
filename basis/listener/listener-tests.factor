USING: io io.streams.string io.streams.duplex listener
tools.test parser math namespaces continuations vocabs kernel
compiler.units eval vocabs.parser ;
IN: listener.tests

SYNTAX: hello "Hi" print ;

: parse-interactive ( string -- quot )
    <string-reader> stream-read-quot ;

[
    [ [ ] ] [
        "USE: listener.tests hello" parse-interactive
    ] unit-test
] with-file-vocabs

[
    "debugger" use+

    [ [ \ + 1 2 3 4 ] ]
    [
        [
            "cont" set
            [
                "\\ + 1 2 3 4" parse-interactive
                "cont" get continue-with
            ] ignore-errors
            "USE: debugger :1" eval
        ] callcc1
    ] unit-test
] with-file-vocabs

[ ] [
    [
        "vocabs.loader.test.c" forget-vocab
    ] with-compilation-unit
] unit-test

[
    [
        "USE: vocabs.loader.test.c" parse-interactive
    ] must-fail
] with-file-vocabs

[ ] [
    [
        "vocabs.loader.test.c" forget-vocab
    ] with-compilation-unit
] unit-test

[
    [ ] [
        "IN: listener.tests : hello ( -- )\n\"world\" ;" parse-interactive
        drop
    ] unit-test
] with-file-vocabs
