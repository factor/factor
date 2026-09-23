USING: accessors kernel math.rectangles namespaces tools.test
ui.gadgets ui.gadgets.borders ui.gadgets.borders.private
ui.gadgets.editors ;
USE: ui.test

! Expected geometry below uses unscaled pixels.
f [


! border-pref-dim
{ { 20.0 20.0 } } [
    <multiline-editor> { 5 5 } <border> { 10 10 } border-pref-dim
] unscaled-ui-test unit-test

{ { 110.0 210.0 } } [ <gadget> { 100 200 } >>dim { 5 5 } <border> pref-dim ] unscaled-ui-test unit-test

{ } [ <gadget> { 100 200 } >>dim "g" set ] unscaled-ui-test unit-test

{ } [ "g" get { 0 0 } <border> { 100 200 } >>dim "b" set ] unscaled-ui-test unit-test

{ T{ rect f { 0.0 0.0 } { 100 200 } } } [ "b" get border-child-rect ] unscaled-ui-test unit-test

{ } [ "g" get { 5 5 } <border> { 210 210 } >>dim "b" set ] unscaled-ui-test unit-test

{ T{ rect f { 55.0 5.0 } { 100 200 } } } [ "b" get border-child-rect ] unscaled-ui-test unit-test

{ } [ "b" get { 0 0 } >>align drop ] unscaled-ui-test unit-test

{ { 5.0 5.0 } } [ "b" get { 100 200 } border-loc ] unscaled-ui-test unit-test

{ T{ rect f { 5.0 5.0 } { 100 200 } } } [ "b" get border-child-rect ] unscaled-ui-test unit-test

{ } [ "b" get { 1 1 } >>fill drop ] unscaled-ui-test unit-test

{ T{ rect f { 5.0 5.0 } { 200 200 } } } [ "b" get border-child-rect ] unscaled-ui-test unit-test
] with-ui-test-scale
