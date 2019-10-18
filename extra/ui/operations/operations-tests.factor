IN: temporary
USING: ui.operations ui.commands prettyprint kernel namespaces
tools.test ui.gadgets ui.gadgets.editors parser io
io.streams.string math help help.markup ;

[ drop t ] \ pprint f f f operation construct-boa "op" set

[ [ 3 pprint ] ] [
    3 "op" get operation-command command-quot
] unit-test

[ "3" ] [ [ 3 "op" get invoke-command ] string-out ] unit-test

[ drop t ] \ pprint [ parse ] [ editor-string ] f operation construct-boa
"op" set

[ "[ 4 ]" ] [
    [
        "4" <editor> [ set-editor-string ] keep
        "op" get invoke-command
    ] string-out
] unit-test

[ ] [
    [ { $operations \ + } print-element ] string-out drop
] unit-test
