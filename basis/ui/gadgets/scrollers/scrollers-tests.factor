USING: ui.gadgets ui.gadgets.scrollers namespaces tools.test
kernel models models.compose models.range ui.gadgets.viewports
ui.gadgets.labels ui.gadgets.grids ui.gadgets.frames
ui.gadgets.sliders math math.vectors arrays sequences
tools.test.ui math.rectangles accessors ui.gadgets.buttons
ui.gadgets.packs ;
IN: ui.gadgets.scrollers.tests

[ ] [
    <gadget> "g" set
    "g" get <scroller> "s" set
] unit-test

[ { 100 200 } ] [
    { 100 200 } point>rect "g" get scroll>rect
    "s" get follows>> loc>>
] unit-test

[ ] [ "s" get scroll>bottom ] unit-test
[ t ] [ "s" get follows>> ] unit-test

[ ] [
    <gadget> dup "g" set
    10 1 0 100 <range> 20 1 0 100 <range> 2array <compose>
    <viewport> "v" set
] unit-test

"v" get [
    [ { 10 20 } ] [ "v" get model>> range-value ] unit-test

    [ { 10 20 } ] [ "g" get loc>> vneg viewport-gap v+ scroller-border v+ ] unit-test
] with-grafted-gadget

[ ] [
    <gadget> { 100 100 } >>dim
    dup "g" set <scroller> "s" set
] unit-test

[ ] [ "s" get { 50 50 } >>dim drop ] unit-test

[ ] [ "s" get layout ] unit-test

"s" get [
    [ { 34 34 } ] [ "s" get viewport>> dim>> ] unit-test

    [ { 107 107 } ] [ "s" get viewport>> viewport-dim ] unit-test

    [ ] [ { 0 0 } "s" get scroll ] unit-test

    [ { 0 0 } ] [ "s" get model>> range-min-value ] unit-test

    [ { 107 107 } ] [ "s" get model>> range-max-value ] unit-test

    [ ] [ { 10 20 } "s" get scroll ] unit-test

    [ { 10 20 } ] [ "s" get model>> range-value ] unit-test

    [ { 10 20 } ] [ "s" get viewport>> model>> range-value ] unit-test

    [ { 10 20 } ] [ "g" get loc>> vneg viewport-gap v+ scroller-border v+ ] unit-test
] with-grafted-gadget

<gadget> { 600 400 } >>dim "g1" set
<gadget> { 600 10 } >>dim "g2" set
"g1" get "g2" get add-gadget drop

"g1" get <scroller>
{ 300 300 } >>dim
dup layout
"s" set

[ t ] [
    10 [
        drop
        "g2" get scroll>gadget
        "s" get layout
        "s" get scroller-value
    ] map [ { 3 0 } = ] all?
] unit-test

[ ] [ "Hi" <label> dup "l" set <scroller> "s" set ] unit-test

[ t ] [ "l" get find-scroller "s" get eq? ] unit-test
[ t ] [ "l" get dup find-scroller viewport>> swap child? ] unit-test
[ t ] [ "l" get find-scroller* "s" get eq? ] unit-test
[ f ] [ "s" get viewport>> find-scroller* ] unit-test
[ t ] [ "s" get @right grid-child slider? ] unit-test
[ f ] [ "s" get @right grid-child find-scroller* ] unit-test

[ ] [
    "Click Me" [ [ scroll>gadget ] [ unparent ] bi ] <bevel-button>
    [ <pile> swap add-gadget <scroller> ] keep
    dup quot>> call
    layout
] unit-test

[ t ] [
    <gadget> { 200 200 } >>dim
    [ [ scroll>gadget ] [ unparent ] bi ] <bevel-button>
    dup
    <pile> swap add-gadget <scroller> { 100 100 } >>dim dup layout
    swap dup quot>> call
    dup layout
    model>> dependencies>> [ range-max value>> ] map
    viewport-padding =
] unit-test

\ <scroller> must-infer
