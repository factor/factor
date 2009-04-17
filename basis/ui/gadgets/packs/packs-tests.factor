USING: ui.gadgets.packs ui.gadgets.packs.private
ui.gadgets.labels ui.gadgets ui.gadgets.debug ui.render
ui.baseline-alignment kernel namespaces tools.test math.parser
sequences math.rectangles accessors ;
IN: ui.gadgets.packs.tests

[ t ] [
    { 0 0 } { 100 100 } <rect> clip set

    <pile>
        100 [ number>string <label> add-gadget ] each
    dup layout

    visible-children [ label? ] all?
] unit-test

[ { { 10 30 } } ] [
    { { 10 20 } }
    { { 100 30 } }
    <gadget> vertical >>orientation
    orient
] unit-test

! Test baseline alignment
<shelf> +baseline+ >>align
    5 5 { 10 10 } <baseline-gadget> add-gadget
    10 10 { 10 10 } <baseline-gadget> add-gadget
"g" set

[ ] [ "g" get prefer ] unit-test

[ { 20 15 } ] [ "g" get dim>> ] unit-test

[ V{ { 0 5 } { 10 0 } } ] [
    "g" get
    dup layout
    children>> [ loc>> ] map
] unit-test

! Test mixed baseline and ordinary alignment
<shelf> +baseline+ >>align
    <gadget> { 20 20 } >>dim add-gadget
    10 10 { 10 10 } <baseline-gadget> add-gadget
"g" set

[ { 30 20 } ] [ "g" get pref-dim ] unit-test

[ ] [ "g" get layout ] unit-test

[ V{ { 0 0 } { 20 5 } } ] [
    "g" get children>> [ loc>> ] map
] unit-test

<shelf> +baseline+ >>align
    <gadget> { 15 15 } >>dim add-gadget
    5 5 { 10 10 } <baseline-gadget> add-gadget
"g" set

[ { 25 15 } ] [ "g" get pref-dim ] unit-test

[ ] [ "g" get prefer ] unit-test

[ ] [ "g" get layout ] unit-test

[ V{ { 0 0 } { 15 5 } } ] [
    "g" get children>> [ loc>> ] map
] unit-test

<shelf> +baseline+ >>align
    <gadget> { 20 20 } >>dim add-gadget
    30 30 { 10 50 } <baseline-gadget> add-gadget
"g" set

[ { 30 50 } ] [ "g" get pref-dim ] unit-test

[ ] [ "g" get prefer ] unit-test

[ ] [ "g" get layout ] unit-test

[ V{ { 0 5 } { 20 0 } } ] [
    "g" get children>> [ loc>> ] map
] unit-test

<shelf> +baseline+ >>align
    <gadget> { 30 30 } >>dim add-gadget
    30 4 { 30 30 } <baseline-gadget> add-gadget
"g" set

[ { 60 43 } ] [ "g" get pref-dim ] unit-test

[ ] [ "g" get prefer ] unit-test

[ ] [ "g" get layout ] unit-test

! Baseline alignment without any text gadgets should behave like align=1/2
<shelf> +baseline+ >>align
    <gadget> { 30 30 } >>dim add-gadget
    <gadget> { 30 20 } >>dim add-gadget
"g" set

[ { 60 30 } ] [ "g" get pref-dim ] unit-test

[ ] [ "g" get prefer ] unit-test

[ ] [ "g" get layout ] unit-test

[ V{ { 0 0 } { 30 5 } } ]
[ "g" get children>> [ loc>> ] map ] unit-test

<shelf> +baseline+ >>align
<gadget> { 30 30 } >>dim add-gadget
10 10 { 10 10 } <baseline-gadget> add-gadget
"g" set

[ ] [ "g" get prefer ] unit-test

[ ] [ "g" get layout ] unit-test

[ V{ { 0 0 } { 30 10 } } ]
[ "g" get children>> [ loc>> ] map ] unit-test

<shelf> +baseline+ >>align
<shelf> <gadget> { 30 30 } >>dim add-gadget add-gadget
10 10 { 10 10 } <baseline-gadget> add-gadget
"g" set

[ ] [ "g" get prefer ] unit-test

[ ] [ "g" get layout ] unit-test

[ V{ { 0 0 } { 30 10 } } ]
[ "g" get children>> [ loc>> ] map ] unit-test

<shelf> +baseline+ >>align
<gadget> { 24 24 } >>dim add-gadget
12 9 { 15 15 } <baseline-gadget> add-gadget
"g" set

[ { 39 24 } ] [ "g" get pref-dim ] unit-test