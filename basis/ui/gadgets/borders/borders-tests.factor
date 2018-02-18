USING: accessors kernel math.rectangles namespaces tools.test
ui.gadgets ui.gadgets.borders ui.gadgets.borders.private
ui.gadgets.editors ;

! border-pref-dim
{ { 20 20 } } [
    <multiline-editor> { 5 5 } <border> { 10 10 } border-pref-dim
] unit-test

{ { 110 210 } } [ <gadget> { 100 200 } >>dim { 5 5 } <border> pref-dim ] unit-test

{ } [ <gadget> { 100 200 } >>dim "g" set ] unit-test

{ } [ "g" get { 0 0 } <border> { 100 200 } >>dim "b" set ] unit-test

{ T{ rect f { 0 0 } { 100 200 } } } [ "b" get border-child-rect ] unit-test

{ } [ "g" get { 5 5 } <border> { 210 210 } >>dim "b" set ] unit-test

{ T{ rect f { 55 5 } { 100 200 } } } [ "b" get border-child-rect ] unit-test

{ } [ "b" get { 0 0 } >>align drop ] unit-test

{ { 5 5 } } [ "b" get { 100 200 } border-loc ] unit-test

{ T{ rect f { 5 5 } { 100 200 } } } [ "b" get border-child-rect ] unit-test

{ } [ "b" get { 1 1 } >>fill drop ] unit-test

{ T{ rect f { 5 5 } { 200 200 } } } [ "b" get border-child-rect ] unit-test
