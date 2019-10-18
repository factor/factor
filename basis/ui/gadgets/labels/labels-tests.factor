USING: accessors tools.test ui.gadgets ui.gadgets.labels ;

{ { 119 14 } } [
    <gadget> { 100 14 } >>dim
    <gadget> { 14 14 } >>dim
    label-on-right { 5 5 } >>gap
    pref-dim
] unit-test
