USING: ui.gadgets ui.gadgets.grids tools.test kernel arrays
namespaces math.rectangles accessors ui.gadgets.grids.private
ui.gadgets.debug sequences classes ;
IN: ui.gadgets.grids.tests

: 100x100 ( -- gadget ) <gadget> { 100 100 } >>dim ;

: 200x200 ( -- gadget ) <gadget> { 200 200 } >>dim ;

USE: ui.test

! Expected geometry below uses unscaled pixels.
f [
{ { 0 0 } } [ { } <grid> pref-dim ] unscaled-ui-test unit-test


{ { 100.0 100.0 } } [
    100x100
    1array 1array <grid> pref-dim
] unscaled-ui-test unit-test

{ { 100.0 100.0 } } [
    100x100
    1array 1array <grid> pref-dim
] unscaled-ui-test unit-test

{ { 200.0 100.0 } } [
    100x100
    100x100
    2array 1array <grid> pref-dim
] unscaled-ui-test unit-test

{ { 100.0 200.0 } } [
    100x100
    100x100
    [ 1array ] bi@ 2array <grid> pref-dim
] unscaled-ui-test unit-test

{ } [
    100x100
    100x100
    [ 1array ] bi@ 2array <grid> layout
] unscaled-ui-test unit-test

{ { 230.0 120.0 } { 100.0 100.0 } { 100.0 100.0 } } [
    100x100 dup "a" set
    100x100 dup "b" set
    2array 1array <grid>
    { 10 10 } >>gap
    dup prefer
    dup layout
    dim>>
    "a" get dim>>
    "b" get dim>>
] unscaled-ui-test unit-test

{ } [
    100x100 dup "a" set
    100x100 dup "b" set
    100x100 dup "c" set
    [ 1array ] tri@ 3array
    <grid>
    { 10 10 } >>gap "g" set
] unscaled-ui-test unit-test

{ } [ "g" get prefer ] unscaled-ui-test unit-test
{ } [ "g" get layout ] unscaled-ui-test unit-test

{ { 10 10 } } [ "a" get loc>> ] unscaled-ui-test unit-test
{ { 100.0 100.0 } } [ "a" get dim>> ] unscaled-ui-test unit-test

{ { 10 120.0 } } [ "b" get loc>> ] unscaled-ui-test unit-test
{ { 100.0 100.0 } } [ "b" get dim>> ] unscaled-ui-test unit-test

{ { 10 230.0 } } [ "c" get loc>> ] unscaled-ui-test unit-test
{ { 100.0 100.0 } } [ "c" get dim>> ] unscaled-ui-test unit-test

5 10 { 10 10 } <baseline-gadget>
10 10 { 10 10 } <baseline-gadget> 2array
1array <grid> f >>fill?
"g" set

{ } [ "g" get prefer ] unscaled-ui-test unit-test

{ { 20.0 15.0 } } [ "g" get dim>> ] unscaled-ui-test unit-test

{ V{ { 0.0 5.0 } { 10.0 0.0 } } } [
    "g" get
    dup layout
    children>> [ loc>> ] map
] unscaled-ui-test unit-test

! children-on logic was insufficient
{ } [
    100x100 dup "a" set 200x200 2array
    100x100 dup "b" set 200x200 2array 2array <grid> f >>fill? "g" set
] unscaled-ui-test unit-test

{ } [ "g" get prefer ] unscaled-ui-test unit-test
{ } [ "g" get layout ] unscaled-ui-test unit-test

{ { 0.0 50.0 } } [ "a" get loc>> ] unscaled-ui-test unit-test
{ { 0.0 250.0 } } [ "b" get loc>> ] unscaled-ui-test unit-test

{ gadget { 200 200 } }
[ { 120 20 } "g" get pick-up [ class-of ] [ dim>> ] bi ] unscaled-ui-test unit-test

{ gadget { 200 200 } }
[ { 120 220 } "g" get pick-up [ class-of ] [ dim>> ] bi ] unscaled-ui-test unit-test
] with-ui-test-scale
