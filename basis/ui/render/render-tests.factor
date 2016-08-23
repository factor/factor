USING: accessors colors.constants namespaces tools.test
ui.gadgets.labels ui.pens.gradient ui.render ui.render.private ;
IN: ui.render.tests

: test-pen ( -- pen )
    { COLOR: white COLOR: black } <gradient> ;

{ } [
    "hello" <label> test-pen >>interior
    draw-standard-background
] unit-test
