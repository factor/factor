USING: compiler.units continuations definitions eval io
io.streams.string kernel listener listener.private math namespaces
parser parser.notes tools.test vocabs vocabs.parser words ;
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
    [ [ \ + 1 2 3 4 ] ]
    [
        [
            "cont" set
            [
                "\\ + 1 2 3 4" parse-interactive
                "cont" get continue-with
            ] ignore-errors
            "USE: debugger :1" eval( -- quot )
        ] callcc1
    ] unit-test
] with-file-vocabs

{ } [
    [
        "vocabs.loader.test.c" forget-vocab
    ] with-compilation-unit
] unit-test

[
    [
        "USE: vocabs.loader.test.c" parse-interactive
    ] must-fail
] with-file-vocabs

{ } [
    [
        "vocabs.loader.test.c" forget-vocab
    ] with-compilation-unit
] unit-test

[
    [ ] [
        "IN: listener.tests : hello ( -- string )\n\"world\" ;" parse-interactive
        drop
    ] unit-test
] with-file-vocabs

[ "call" "scratchpad" create-word drop ] with-compilation-unit

[
    { t }
    [
        "call" "scratchpad" lookup-word
        [ "call" search ] with-interactive-vocabs
        eq?
    ] unit-test
] with-file-vocabs

[ "call" "scratchpad" lookup-word forget ] with-compilation-unit

[
    { t } [
        "[ ]" [
            t parser-quiet? [
                { } listener-step drop
                parser-quiet? get
            ] with-variable
        ] with-string-reader
    ] unit-test
] with-file-vocabs
