USING: io io.streams.string listener tools.test parser
math namespaces continuations vocabs ;
IN: temporary

: hello "Hi" print ; parsing

[ [ ] ] [
    "USE: temporary hello" <string-reader> parse-interactive
] unit-test

[
    file-vocabs
    "debugger" use+

    [ [ \ + 1 2 3 4 ] ]
    [
        [
            "cont" set
            [
                "\\ + 1 2 3 4" 
                <string-reader>
                parse-interactive "cont" get continue-with
            ] catch
            ":1" eval
        ] callcc1
    ] unit-test
] with-scope

[ ] [ "vocabs.loader.test.c" forget-vocab ] unit-test

[
    "USE: vocabs.loader.test.c" <string-reader>
    parse-interactive
] unit-test-fails

[ ] [ "vocabs.loader.test.c" forget-vocab ] unit-test
