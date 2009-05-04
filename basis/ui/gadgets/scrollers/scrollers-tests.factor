USING: ui.gadgets ui.gadgets.scrollers namespaces tools.test
kernel models models.product models.range ui.gadgets.viewports
ui.gadgets.labels ui.gadgets.grids ui.gadgets.sliders math
math.vectors arrays sequences ui.gadgets.debug math.rectangles
accessors ui.gadgets.buttons ui.gadgets.packs
ui.gadgets.scrollers.private ;
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
    10 1 0 100 <range> 20 1 0 100 <range> 2array <product>
    <viewport> "v" set
] unit-test

"v" get [
    [ { 10 20 } ] [ "v" get model>> range-value ] unit-test

    [ { 10 20 } ] [ "g" get loc>> vneg ] unit-test
] with-grafted-gadget

[ ] [
    <gadget> { 100 100 } >>dim
    dup "g" set <scroller> "s" set
] unit-test

[ ] [ "s" get { 50 50 } >>dim drop ] unit-test

[ ] [ "s" get layout ] unit-test

"s" get [
    [ { 31 31 } ] [ "s" get viewport>> dim>> ] unit-test

    [ { 100 100 } ] [ "s" get viewport>> gadget-child pref-dim ] unit-test

    [ ] [ { 0 0 } "s" get set-scroll-position ] unit-test

    [ { 0 0 } ] [ "s" get model>> range-min-value ] unit-test

    [ { 100 100 } ] [ "s" get model>> range-max-value ] unit-test

    [ ] [ { 10 20 } "s" get set-scroll-position ] unit-test

    [ { 10 20 } ] [ "s" get model>> range-value ] unit-test

    [ { 10 20 } ] [ "s" get viewport>> model>> range-value ] unit-test

    [ { 10 20 } ] [ "g" get loc>> vneg ] unit-test
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
        "s" get scroll-position
    ] map [ { 0 0 } = ] all?
] unit-test

[ ] [ "Hi" <label> dup "l" set <scroller> "s" set ] unit-test

[ t ] [ "l" get find-scroller "s" get eq? ] unit-test
[ t ] [ "l" get dup find-scroller viewport>> swap child? ] unit-test
[ t ] [ "l" get find-scroller* "s" get eq? ] unit-test
[ f ] [ "s" get viewport>> find-scroller* ] unit-test
[ t ] [ "s" get { 1 0 } grid-child slider? ] unit-test
[ f ] [ "s" get { 1 0 } grid-child find-scroller* ] unit-test

[ ] [
    "Click Me" [ [ scroll>gadget ] [ unparent ] bi ] <border-button>
    [ <pile> swap add-gadget <scroller> ] keep
    dup quot>> call
    layout
] unit-test

[ t ] [
    <gadget> { 200 200 } >>dim
    [ [ scroll>gadget ] [ unparent ] bi ] <border-button>
    dup
    <pile> swap add-gadget <scroller> { 100 100 } >>dim dup layout
    swap dup quot>> call
    dup layout
    model>> dependencies>> [ range-max value>> ] map
    { 0 0 } =
] unit-test
