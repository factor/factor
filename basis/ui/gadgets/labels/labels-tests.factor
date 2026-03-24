USING: accessors arrays fonts kernel opengl sequences strings
tools.test ui.gadgets ui.gadgets.labels ui.text ;

{ { 119 14 } } [
    <gadget> { 100 14 } >>dim
    <gadget> { 14 14 } >>dim
    label-on-right { 5 5 } >>gap
    pref-dim
] unit-test

{ t } [
    1001 CHAR: a <string>
    [ <label> pref-dim ]
    [ sans-serif-font swap text-dim first2 gl-ceiling 2array [ ?>integer ] map ] bi
    =
] unit-test
