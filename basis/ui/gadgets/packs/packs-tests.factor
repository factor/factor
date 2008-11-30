IN: ui.gadgets.packs.tests
USING: ui.gadgets.packs ui.gadgets.labels ui.gadgets ui.render
kernel namespaces tools.test math.parser sequences math.geometry.rect
accessors ;

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
    <gadget> { 0 1 } >>orientation
    orient
] unit-test
