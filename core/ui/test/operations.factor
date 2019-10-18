IN: temporary
USING: operations prettyprint kernel namespaces test gadgets
gadgets-text parser io math help ;

[ drop t ] \ pprint f f f <operation> "op" set

[ [ 3 pprint ] ] [
    3 "op" get operation-command command-quot
] unit-test

[ "3" ] [ [ 3 "op" get invoke-command ] string-out ] unit-test

[ drop t ] \ pprint [ parse ] [ editor-string ] f <operation>
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
