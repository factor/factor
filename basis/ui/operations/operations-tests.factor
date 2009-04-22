IN: ui.operations.tests
USING: ui.operations ui.commands prettyprint kernel namespaces
tools.test ui.gadgets ui.gadgets.editors parser io
io.streams.string math help help.markup accessors ;

: my-pprint ( obj -- ) pprint ;

[ drop t ] \ my-pprint [ ] f operation boa "op" set

[ [ 3 my-pprint ] ] [
    3 "op" get command>> command-quot
] unit-test

[ "3" ] [ [ 3 "op" get invoke-command ] with-string-writer ] unit-test

[ drop t ] \ my-pprint [ editor-string ] f operation boa
"op" set

[ "\"4\"" ] [
    [
        "4" <editor> [ set-editor-string ] keep
        "op" get invoke-command
    ] with-string-writer
] unit-test

[ ] [
    [ { $operations \ + } print-element ] with-string-writer drop
] unit-test
