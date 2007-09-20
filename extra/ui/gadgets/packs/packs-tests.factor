IN: temporary
USING: ui.gadgets.packs ui.gadgets.labels ui.gadgets ui.render
kernel namespaces tools.test math.parser sequences ;

[ t ] [
    { 0 0 } { 100 100 } <rect> clip set

    [
        100 [ number>string <label> gadget, ] each
    ] make-pile

    dup layout

    visible-children [ label? ] all?
] unit-test
