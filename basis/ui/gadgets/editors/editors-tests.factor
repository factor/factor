USING: accessors ui.gadgets.editors tools.test kernel io
io.streams.plain definitions namespaces ui.gadgets
ui.gadgets.grids prettyprint documents ui.gestures ui.gadgets.debug
models documents.elements ui.gadgets.scrollers ui.gadgets.line-support
sequences ;
IN: ui.gadgets.editors.tests

[ "foo bar" ] [
    <editor> "editor" set
    "editor" get [
        "foo bar" "editor" get set-editor-string
        "editor" get one-line-elt select-elt
        "editor" get gadget-selection
    ] with-grafted-gadget
] unit-test

[ "baz quux" ] [
    <editor> "editor" set
    "editor" get [
        "foo bar\nbaz quux" "editor" get set-editor-string
        "editor" get one-line-elt select-elt
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
        { 0 3 } "editor" get caret>> set-model
        "editor" get select-word
        "editor" get gadget-selection
    ] with-grafted-gadget
] unit-test

\ <editor> must-infer

"hello" <model> <model-field> "field" set

"field" get [
    [ "hello" ] [ "field" get field-model>> value>> ] unit-test
] with-grafted-gadget

[ "Hello world." ] [ "Hello    \n    world." join-lines ] unit-test
[ "  Hello world.  " ] [ "  Hello    \n    world.  " join-lines ] unit-test
[ "  Hello world. Goodbye." ] [ "  Hello    \n    world.  \n  Goodbye." join-lines ] unit-test

[ ] [ <editor> com-join-lines ] unit-test
[ ] [ <editor> "A" over set-editor-string com-join-lines ] unit-test
[ "A B" ] [ <editor> "A\nB" over set-editor-string [ com-join-lines ] [ editor-string ] bi ] unit-test

[ 2 ] [ <editor> 20 >>min-rows 20 >>min-cols pref-viewport-dim length ] unit-test

[ 20 ] [
    <editor> 20 >>min-rows 20 >>min-cols
    dup pref-viewport-dim >>dim
    visible-lines
] unit-test

