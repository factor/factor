USING: ui.gadgets.editors tools.test kernel io io.streams.plain
definitions namespaces ui.gadgets
ui.gadgets.grids prettyprint documents ui.gestures
tools.test.inference tools.test.ui models ;

[ "foo bar" ] [
    <editor> "editor" set
    "editor" get [
        "foo bar" "editor" get set-editor-string
        "editor" get T{ one-line-elt } select-elt
        "editor" get gadget-selection
    ] with-grafted-gadget
] unit-test

[ "baz quux" ] [
    <editor> "editor" set
    "editor" get [
        "foo bar\nbaz quux" "editor" get set-editor-string
        "editor" get T{ one-line-elt } select-elt
        "editor" get gadget-selection
    ] with-grafted-gadget
] unit-test

[ ] [
    <editor> "editor" set
    "editor" get [
        "foo bar\nbaz quux" "editor" get set-editor-string
        4 hand-click# set
        "editor" get position-caret
    ] with-grafted-gadget
] unit-test

[ "bar" ] [
    <editor> "editor" set
    "editor" get [
        "bar\nbaz quux" "editor" get set-editor-string
        { 0 3 } "editor" get editor-caret set-model
        "editor" get select-word
        "editor" get gadget-selection
    ] with-grafted-gadget
] unit-test

\ <editor> must-infer

"hello" <model> <field> "field" set

"field" get [
    [ "hello" ] [ "field" get field-model model-value ] unit-test
] with-grafted-gadget
