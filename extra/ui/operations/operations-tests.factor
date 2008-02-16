IN: temporary
USING: ui.operations ui.commands prettyprint kernel namespaces
tools.test ui.gadgets ui.gadgets.editors parser io
io.streams.string math help help.markup ;

: my-pprint pprint ;

[ drop t ] \ my-pprint [ ] [ ] f operation construct-boa "op" set

[ [ 3 my-pprint ] ] [
    3 "op" get operation-command command-quot
] unit-test

[ "3" ] [ [ 3 "op" get invoke-command ] with-string-writer ] unit-test

[ drop t ] \ my-pprint [ ] [ editor-string ] f operation construct-boa
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
