USING: ui.gadgets.packs ui.gadgets.packs.private
ui.gadgets.labels ui.gadgets ui.gadgets.debug ui.render
ui.baseline-alignment kernel namespaces tools.test math.parser
sequences math.rectangles accessors math ;
USE: ui.test

! Expected geometry below uses unscaled pixels.
f [


{ t } [
    { 0 0 } { 100 100 } <rect> clip set

    <pile>
        100 [ number>string <label> add-gadget ] each-integer
    dup layout

    visible-children [ label? ] all?
] unscaled-ui-test unit-test

{ { { 10.0 30.0 } } } [
    { { 10 20 } }
    { { 100 30 } }
    <gadget> vertical >>orientation
    orient
] unscaled-ui-test unit-test

! Test baseline alignment
<shelf> +baseline+ >>align
    5 5 { 10 10 } <baseline-gadget> add-gadget
    10 10 { 10 10 } <baseline-gadget> add-gadget
"g" set

{ } [ "g" get prefer ] unscaled-ui-test unit-test

{ { 20 15.0 } } [ "g" get dim>> ] unscaled-ui-test unit-test

{ V{ { 0.0 5.0 } { 10.0 0.0 } } } [
    "g" get
    dup layout
    children>> [ loc>> ] map
] unscaled-ui-test unit-test

! Test mixed baseline and ordinary alignment
<shelf> +baseline+ >>align
    <gadget> { 20 20 } >>dim add-gadget
    10 10 { 10 10 } <baseline-gadget> add-gadget
"g" set

{ { 30 20.0 } } [ "g" get pref-dim ] unscaled-ui-test unit-test

{ } [ "g" get layout ] unscaled-ui-test unit-test

{ V{ { 0.0 0.0 } { 20.0 5.0 } } } [
    "g" get children>> [ loc>> ] map
] unscaled-ui-test unit-test

<shelf> +baseline+ >>align
    <gadget> { 15 15 } >>dim add-gadget
    5 5 { 10 10 } <baseline-gadget> add-gadget
"g" set

{ { 25 15.0 } } [ "g" get pref-dim ] unscaled-ui-test unit-test

{ } [ "g" get prefer ] unscaled-ui-test unit-test

{ } [ "g" get layout ] unscaled-ui-test unit-test

{ V{ { 0.0 0.0 } { 15.0 5.0 } } } [
    "g" get children>> [ loc>> ] map
] unscaled-ui-test unit-test

<shelf> +baseline+ >>align
    <gadget> { 20 20 } >>dim add-gadget
    30 30 { 10 50 } <baseline-gadget> add-gadget
"g" set

{ { 30 50.0 } } [ "g" get pref-dim ] unscaled-ui-test unit-test

{ } [ "g" get prefer ] unscaled-ui-test unit-test

{ } [ "g" get layout ] unscaled-ui-test unit-test

{ V{ { 0.0 5.0 } { 20.0 0.0 } } } [
    "g" get children>> [ loc>> ] map
] unscaled-ui-test unit-test

<shelf> +baseline+ >>align
    <gadget> { 30 30 } >>dim add-gadget
    30 4 { 30 30 } <baseline-gadget> add-gadget
"g" set

{ { 60 43.0 } } [ "g" get pref-dim ] unscaled-ui-test unit-test

{ } [ "g" get prefer ] unscaled-ui-test unit-test

{ } [ "g" get layout ] unscaled-ui-test unit-test

! Baseline alignment without any text gadgets should behave like align=1/2
<shelf> +baseline+ >>align
    <gadget> { 30 30 } >>dim add-gadget
    <gadget> { 30 20 } >>dim add-gadget
"g" set

{ { 60 30 } } [ "g" get pref-dim ] unscaled-ui-test unit-test

{ } [ "g" get prefer ] unscaled-ui-test unit-test

{ } [ "g" get layout ] unscaled-ui-test unit-test

{ V{ { 0.0 0.0 } { 30.0 5.0 } } }
[ "g" get children>> [ loc>> ] map ] unscaled-ui-test unit-test

<shelf> +baseline+ >>align
<gadget> { 30 30 } >>dim add-gadget
10 10 { 10 10 } <baseline-gadget> add-gadget
"g" set

{ } [ "g" get prefer ] unscaled-ui-test unit-test

{ } [ "g" get layout ] unscaled-ui-test unit-test

{ V{ { 0.0 0.0 } { 30.0 10.0 } } }
[ "g" get children>> [ loc>> ] map ] unscaled-ui-test unit-test

<shelf> +baseline+ >>align
<shelf> <gadget> { 30 30 } >>dim add-gadget add-gadget
10 10 { 10 10 } <baseline-gadget> add-gadget
"g" set

{ } [ "g" get prefer ] unscaled-ui-test unit-test

{ } [ "g" get layout ] unscaled-ui-test unit-test

{ V{ { 0.0 0.0 } { 30.0 10.0 } } }
[ "g" get children>> [ loc>> ] map ] unscaled-ui-test unit-test

<shelf> +baseline+ >>align
<gadget> { 24 24 } >>dim add-gadget
12 9 { 15 15 } <baseline-gadget> add-gadget
"g" set

{ { 39 24.0 } } [ "g" get pref-dim ] unscaled-ui-test unit-test
] with-ui-test-scale
