USING: accessors arrays colors continuations dlists documents.private fonts fry help
help.markup help.stylesheet help.syntax help.topics inspector io
io.streams.string io.styles kernel literals locals math models models.range
namespaces prettyprint see sequences strings tools.test ui.clipboards ui.gadgets
ui.gadgets.debug ui.gadgets.panes ui.gadgets.panes.private
ui.gadgets.scrollers ui.gadgets.viewports ui.gadgets.worlds ui.gestures ui.theme ;
FROM: sets => in? ;
FROM: ui.render => selected-children ;
IN: ui.gadgets.panes.tests

! Fractional bottom limits must use the same rounding as range-value.
{ t } [ 900.75 100 0 1000.75 1 <range> range-at-bottom? ] unit-test
{ t } [ 900 100 0 1000.75 1 <range> range-at-bottom? ] unit-test
{ f } [ 899 100 0 1000.75 1 <range> range-at-bottom? ] unit-test
{ t } [ 900 100 0 1000 1 <range> range-at-bottom? ] unit-test
{ f } [ 899 100 0 1000 1 <range> range-at-bottom? ] unit-test
! A fractional page can put the limit just below an integer.
{ t } [ 899 100.25 0 1000 1 <range> range-at-bottom? ] unit-test
{ f } [ 898 100.25 0 1000 1 <range> range-at-bottom? ] unit-test
! Content fitting in the viewport and non-unit scroll steps.
{ t } [ 0 100 0 50 1 <range> range-at-bottom? ] unit-test
{ t } [ 898 100 0 999 2 <range> range-at-bottom? ] unit-test
{ f } [ 896 100 0 999 2 <range> range-at-bottom? ] unit-test

! A write larger than the viewport must target the new content height.
:: pane-bulk-scroll-test ( scrolls? position -- first? laid-out? next? x y )
    <pane> scrolls? >>scrolls? :> pane
    pane <pane-stream> :> stream
    <gadget> { 500 1000 } >>dim stream write-gadget
    stream stream-nl
    pane <scroller> { 200 100 } >>dim :> scroller
    scroller layout
    position scroller set-scroll-position
    scroller model>> dependencies>> second :> range
    100 [ "line\n" ] replicate concat stream stream-write
    range range-at-bottom?
    scroller layout
    range range-at-bottom?
    "next\n" stream stream-write
    scroller layout
    range range-at-bottom?
    scroller scroll-position first2 ;

{ t t t 20 } [ t { 20 100000 } pane-bulk-scroll-test drop ] unit-test
! Preserve horizontal scrolling and respect a reader who has scrolled up.
{ f f f 20 30 } [ t { 20 30 } pane-bulk-scroll-test ] unit-test
{ f f f 20 30 } [ f { 20 30 } pane-bulk-scroll-test ] unit-test

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

:: pane-written-text ( string -- text )
    <pane> :> pane
    string pane <pane-stream> stream-write
    pane current>> gadget-text ;

! A single large write must not repeatedly copy the growing label.
{ t } [
    10,000,000 CHAR: a <string> dup pane-written-text =
] unit-test

! The ASCII shortcut must retain split-lines semantics on every backend,
! including all supported separators, CRLF pairs, and trailing empties.
{ t } [
    [let
        5000 CHAR: a <string> :> prefix
        { "" "\n" "\r" "\r\n" "\v" "\f" "\x1c" "\x1d" "\x1e"
          "\u000085" "\u002028" "\u002029" "λ" "\u01f600" } [| suffix |
            prefix suffix append [ pane-lines ] [ ?split-lines ] bi =
            prefix suffix append "tail" append [ pane-lines ] [ ?split-lines ] bi = and
        ] all?
    ]
] unit-test

! Printed output remains a snapshot if the caller mutates its string.
{ CHAR: a } [
    5000 CHAR: a <string> dup pane-lines first
    [ CHAR: b 0 rot set-nth ] dip first
] unit-test

! The old fixed-size splitter made no progress on an oversized grapheme.
{ t } [
    "a" 5000 0x0301 <string> append dup pane-written-text =
] unit-test

! Formatted output follows the same path and preserves its style.
:: formatted-pane-text-test ( -- text? style? )
    10,000 CHAR: a <string> :> text
    H{ { foreground COLOR: red } } :> style
    <pane> :> pane
    text style pane <pane-stream> stream-format
    pane current>> find-styled-label
    [ text>> text = ] [ style>> style = ] bi ;

{ t t } [ formatted-pane-text-test ] unit-test

:: large-pane-copy-test ( -- copied? highlighted? )
    10,000,000 CHAR: a <string> :> text
    <pane> :> pane
    text pane <pane-stream> stream-write
    pane { 1 0 0 } >>caret { 1 0 0 } >>mark drop
    <clipboard> :> buffer
    buffer clipboard [ pane com-copy ] with-variable
    buffer clipboard-contents text =
    pane selected-children drop
    pane current>> find-styled-label swap in? ;

{ t t } [ large-pane-copy-test ] unit-test

! Autoscroll targets a one-pixel pointer rectangle, even on a huge label.
:: pane-selection-scroll-test ( -- loc dim )
    <pane> :> pane
    pane <scroller> :> scroller
    hand-loc get-global :> previous
    [
        { 35 12 } hand-loc set-global
        pane scroll-selection-pointer
    ] [ previous hand-loc set-global ] finally
    scroller follows>> [ loc>> ] [ dim>> ] bi ;

{ { 35.0 12.0 } { 1 1 } } [ pane-selection-scroll-test ] unit-test

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
