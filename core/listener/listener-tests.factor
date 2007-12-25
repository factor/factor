USING: io io.streams.string io.streams.duplex listener
tools.test parser math namespaces continuations vocabs kernel ;
IN: temporary

: hello "Hi" print ; parsing

: parse-interactive ( string -- quot )
    <string-reader> stream-read-quot ;

[ [ ] ] [
    "USE: temporary hello" parse-interactive
] unit-test

[
    file-vocabs
    "debugger" use+

    [ [ \ + 1 2 3 4 ] ]
    [
        [
            "cont" set
            [
                "\\ + 1 2 3 4" parse-interactive
                "cont" get continue-with
            ] catch
            "USE: debugger :1" eval
        ] callcc1
    ] unit-test
] with-scope

[ ] [
    "vocabs.loader.test.c" forget-vocab
] unit-test

[
    "USE: vocabs.loader.test.c" parse-interactive
] unit-test-fails

[ ] [
    "vocabs.loader.test.c" forget-vocab
] unit-test

[ ] [
    "IN: temporary : hello\n\"world\" ;" parse-interactive
    drop
] unit-test
