USING: ui.gadgets.packs ui.gadgets.packs.private ui.gadgets.labels
ui.gadgets ui.gadgets.debug ui.render kernel namespaces tools.test
math.parser sequences math.rectangles accessors ;
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

<shelf> +baseline+ >>align
    5 { 10 10 } <baseline-gadget> add-gadget
    10 { 10 10 } <baseline-gadget> add-gadget
"g" set

[ ] [ "g" get prefer ] unit-test

[ { 20 15 } ] [ "g" get dim>> ] unit-test

[ V{ { 0 5 } { 10 0 } } ] [
    "g" get
    dup layout
    children>> [ loc>> ] map
] unit-test