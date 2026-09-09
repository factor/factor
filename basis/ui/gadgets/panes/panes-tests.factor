USING: accessors arrays colors continuations dlists fonts fry help
help.markup help.stylesheet help.syntax help.topics inspector io
io.streams.string io.styles kernel literals locals math models
namespaces prettyprint see sequences tools.test ui.gadgets
ui.gadgets.debug ui.gadgets.panes ui.gadgets.panes.private
ui.gadgets.worlds ui.gestures ui.theme ;
IN: ui.gadgets.panes.tests

: #children ( -- n ) "pane" get children>> length ;

{ } [ <pane> "pane" set ] unit-test

{ } [ #children "num-children" set ] unit-test

{ } [
    "pane" get <pane-stream> [ 100 [ . ] each-integer ] with-output-stream*
] unit-test

{ t } [ #children "num-children" get = ] unit-test

: test-gadget-text ( quot -- ? )
    '[ _ call( -- ) ]
    [ make-pane gadget-text dup print "======" print ]
    [ with-string-writer dup print ] bi = ;

{ t } [ [ "hello" write ] test-gadget-text ] unit-test
{ t } [ [ "hello" pprint ] test-gadget-text ] unit-test
{ t } [
    [
        H{ { wrap-margin 100 } } [ "hello" pprint ] with-nesting
    ] test-gadget-text
] unit-test
{ t } [
    [
        H{ { wrap-margin 100 } } [
            H{ } [
                "hello" pprint
            ] with-style
        ] with-nesting
    ] test-gadget-text
] unit-test
{ t } [ [ [ 1 2 3 ] pprint ] test-gadget-text ] unit-test
{ t } [ [ \ + describe ] test-gadget-text ] unit-test
{ t } [ [ \ = see ] test-gadget-text ] unit-test
{ t } [ [ \ = print-topic ] test-gadget-text ] unit-test

{ t } [
    [
        title-style get [
                "Hello world" write
        ] with-style
    ] test-gadget-text
] unit-test


{ t } [
    [
        title-style get [
                "Hello world" write
        ] with-nesting
    ] test-gadget-text
] unit-test

{ t } [
    [
        title-style get [
            title-style get [
                "Hello world" write
            ] with-nesting
        ] with-style
    ] test-gadget-text
] unit-test

{ t } [
    [
        title-style get [
            title-style get [
                [ "Hello world" write ] ($block)
            ] with-nesting
        ] with-style
    ] test-gadget-text
] unit-test

{ t } [
    [
        last-element off
        \ = >link $title
        "Hello world" print-content
    ] test-gadget-text
] unit-test

{ t } [
    [ { { "a\n" } } simple-table. ] test-gadget-text
] unit-test

{ t } [
    [ { { "a" } } simple-table. "x" write ] test-gadget-text
] unit-test

{ t } [
    [ H{ } [ { { "a" } } simple-table. ] with-nesting "x" write ] test-gadget-text
] unit-test

ARTICLE: "test-article-1" "This is a test article"
"Hello world, how are you today." ;

{ t } [ [ "test-article-1" $title ] test-gadget-text ] unit-test

{ t } [ [ "test-article-1" print-topic ] test-gadget-text ] unit-test

ARTICLE: "test-article-2" "This is a test article"
"Hello world, how are you today."
{ $table { "a" "b" } { "c" "d" } } ;

{ t } [ [ "test-article-2" print-topic ] test-gadget-text ] unit-test

<pane> [ \ = see ] with-pane
<pane> [ \ = print-topic ] with-pane

{ } [
    \ = <model> [ see ] <pane-control> [ ] with-grafted-gadget
] unit-test

: <test-pane> ( -- foo )
    <gadget> pane new-pane ;

{ t } [ <test-pane> dup input>> child? ] unit-test
{ t } [ <test-pane> dup last-line>> child? ] unit-test

:: with-selection-hand-state ( quot -- )
    hand-loc get-global :> original-loc
    hand-click-loc get-global :> original-click-loc
    hand-clicked get-global :> original-clicked
    [ <dlist> \ gesture-queue quot with-variable ] [
        original-loc hand-loc set-global
        original-click-loc hand-click-loc set-global
        original-clicked hand-clicked set-global
    ] finally ; inline

! Dragging an output selection must receive keyboard focus before
! button-up, so Copy is delivered to the pane while the mouse is held.
{ t f t t } [
    [
        <test-pane> "selection-pane" set
        <world-attributes> "selection-pane" get 1array >>gadgets
        <world> t >>focused? "selection-world" set
        "selection-pane" get input>> request-focus
        { 0 0 } hand-loc set-global
        { 0 0 } hand-click-loc set-global
        "selection-pane" get hand-clicked set-global
        "selection-pane" get begin-selection
        "selection-pane" get extend-selection
        "selection-world" get focus-path last
        "selection-pane" get input>> eq?
        "selection-pane" get selecting?>>
        { 20 20 } hand-loc set-global
        "selection-pane" get extend-selection
        "selection-pane" get selecting?>>
        "selection-world" get focus-path last
        "selection-pane" get eq?
    ] with-selection-hand-state
] unit-test

! smash-line
${
    ""
    T{ font
        { name $[ default-sans-serif-font-name ] }
        { size $[ default-font-size ] }
        { foreground $[ text-color ] }
        { background $[ content-background ] }
    }
} [
    <pane> dup current>> smash-line [ text>> ] [ font>> ] bi
] unit-test
