USING: ui.gadgets ui.gadgets.labels ui.gadgets.labelled
ui.gadgets.packs ui.gadgets.frames ui.gadgets.grids namespaces
kernel tools.test ui.gadgets.buttons sequences ;
IN: temporary

TUPLE: testing ;


[ ] [
    T{ testing } [ "Hey" <label> ] "Testing"
    build-closable-gadget "g" set
] unit-test

[ t ] [ "g" get testing? ] unit-test

[ t ] [ "g" get delegate closable-gadget? ] unit-test

[ t ] [ "g" get closable-gadget-content label? ] unit-test

[ ] [
    <pile> "p" set
    "g" get "p" get add-gadget
    "g" get @top grid-child @left grid-child
    dup button-quot call
] unit-test

[ f ] [ "g" get "p" get gadget-children memq? ] unit-test
