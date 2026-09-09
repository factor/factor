USING: accessors ui.gadgets.editors ui.gadgets.editors.private
tools.test kernel io io.streams.plain definitions namespaces
ui.gadgets ui.gadgets.grids prettyprint documents ui.gestures
ui.gadgets.debug models documents.elements ui.gadgets.scrollers
ui.gadgets.line-support sequences ;

USING: arrays assocs colors continuations fonts locals math namespaces
opengl math.rectangles sequences.generalizations ui.render ui.text ui.text.private ;
IN: ui.gadgets.editors.tests

SINGLETON: measurement-test-renderer
SYMBOL: measurement-count

M: measurement-test-renderer string-dim
    measurement-count [ 1 + ] change
    nip length 10 2array ;

:: test-editor-measurement-cache ( -- counts retained )
    <editor> :> editor
    sans-serif-font :> font
    0 measurement-count [
        measurement-test-renderer font-renderer [
            font { "a" "bbbb" "a" } editor editor-text-dim { 4 30 } assert=
            measurement-count get
            font { "a" "bbbb" "a" } editor editor-text-dim { 4 30 } assert=
            measurement-count get
            font { "a" "cc" } editor editor-text-dim { 2 20 } assert=
            measurement-count get
            font COLOR: red font-with-foreground
            { "a" "cc" } editor editor-text-dim { 2 20 } assert=
            measurement-count get
            font 24 font-with-size
            { "a" "cc" } editor editor-text-dim { 2 20 } assert=
            measurement-count get 5 narray
            editor text-dim-cache>> dims>> assoc-size
        ] with-variable
    ] with-variable ;

{ { 2 2 3 3 5 } 2 } [ test-editor-measurement-cache ] unit-test

:: test-visible-selection ( -- count columns reversed? offscreen-count )
    <editor> 10 >>line-height :> editor
    10000 [ "abc" ] replicate editor model>> set-model
    { 0 0 } editor mark>> set-model
    { 9999 3 } editor caret>> set-model
    { 0 0 } origin [
        { 0 1000 } { 800 400 } <rect> clip [
            editor compute-selection :> selected
            selected assoc-size 100 selected at
            { 9999 3 } editor mark>> set-model
            { 0 0 } editor caret>> set-model
            editor compute-selection selected =
            { 1 0 } editor mark>> set-model
            editor compute-selection assoc-size
        ] with-variable
    ] with-variable ;

{ 41 { 0 3 } t 0 } [ test-visible-selection ] unit-test

{ "foo bar" } [
    <editor> "editor" set
    "editor" get [
        "foo bar" "editor" get set-editor-string
        "editor" get one-line-elt select-elt
        "editor" get gadget-selection
    ] with-grafted-gadget
] unit-test

{ "baz quux" } [
    <editor> "editor" set
    "editor" get [
        "foo bar\nbaz quux" "editor" get set-editor-string
        "editor" get one-line-elt select-elt
        "editor" get gadget-selection
    ] with-grafted-gadget
] unit-test

{ } [
    <editor> "editor" set
    "editor" get [
        "foo bar\nbaz quux" "editor" get set-editor-string
        4 hand-click# set
        "editor" get position-caret
    ] with-grafted-gadget
] unit-test

{ "bar" } [
    <editor> "editor" set
    "editor" get [
        "bar\nbaz quux" "editor" get set-editor-string
        { 0 3 } "editor" get caret>> set-model
        "editor" get select-word
        "editor" get gadget-selection
    ] with-grafted-gadget
] unit-test

"hello" <model> <model-field> "field" set

"field" get [
    [ "hello" ] [ "field" get field-model>> value>> ] unit-test
] with-grafted-gadget

{ "Hello world." } [ "Hello    \n    world." join-lines ] unit-test
{ "  Hello world.  " } [ "  Hello    \n    world.  " join-lines ] unit-test
{ "  Hello world. Goodbye." } [ "  Hello    \n    world.  \n  Goodbye." join-lines ] unit-test

{ } [ <editor> com-join-lines ] unit-test
{ } [ <editor> "A" over set-editor-string com-join-lines ] unit-test
{ "A B" } [ <editor> "A\nB" over set-editor-string [ com-join-lines ] [ editor-string ] bi ] unit-test
{ "A B\nC\nD" } [ <editor> "A\nB\nC\nD" over set-editor-string { 0 0 } over set-caret dup mark>caret [ com-join-lines ] [ editor-string ] bi ] unit-test
{ "A\nB C\nD" } [ <editor> "A\nB\nC\nD" over set-editor-string { 1 0 } over set-caret dup mark>caret [ com-join-lines ] [ editor-string ] bi ] unit-test
{ "A\nB\nC D" } [ <editor> "A\nB\nC\nD" over set-editor-string { 2 0 } over set-caret dup mark>caret [ com-join-lines ] [ editor-string ] bi ] unit-test

{ 2 } [ <editor> 20 >>min-rows 20 >>min-cols pref-viewport-dim length ] unit-test

{ 20 } [
    <editor> 20 >>min-rows 20 >>min-cols
    dup pref-viewport-dim >>dim
    visible-lines
] unit-test
