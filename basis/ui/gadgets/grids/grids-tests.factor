USING: ui.gadgets ui.gadgets.grids tools.test kernel arrays
namespaces math.rectangles accessors ui.gadgets.grids.private
ui.gadgets.debug sequences ;
IN: ui.gadgets.grids.tests

[ { 0 0 } ] [ { } <grid> pref-dim ] unit-test

: 100x100 ( -- gadget ) <gadget> { 100 100 } >>dim ;

[ { 100 100 } ] [
    100x100
    1array 1array <grid> pref-dim
] unit-test

[ { 100 100 } ] [
    100x100
    1array 1array <grid> pref-dim
] unit-test

[ { 200 100 } ] [
    100x100
    100x100
    2array 1array <grid> pref-dim
] unit-test

[ { 100 200 } ] [
    100x100
    100x100
    [ 1array ] bi@ 2array <grid> pref-dim
] unit-test

[ ] [
    100x100
    100x100
    [ 1array ] bi@ 2array <grid> layout
] unit-test

[ { 230 120 } { 100 100 } { 100 100 } ] [
    100x100 dup "a" set
    100x100 dup "b" set
    2array 1array <grid>
    { 10 10 } >>gap
    dup prefer
    dup layout
    dim>>
    "a" get dim>>
    "b" get dim>>
] unit-test

[ ] [
    100x100 dup "a" set
    100x100 dup "b" set
    100x100 dup "c" set
    [ 1array ] tri@ 3array
    <grid>
    { 10 10 } >>gap "g" set
] unit-test

[ ] [ "g" get prefer ] unit-test
[ ] [ "g" get layout ] unit-test

[ { 10 10 } ] [ "a" get loc>> ] unit-test
[ { 100 100 } ] [ "a" get dim>> ] unit-test

[ { 10 120 } ] [ "b" get loc>> ] unit-test
[ { 100 100 } ] [ "b" get dim>> ] unit-test

[ { 10 230 } ] [ "c" get loc>> ] unit-test
[ { 100 100 } ] [ "c" get dim>> ] unit-test

5 10 { 10 10 } <baseline-gadget>
10 10 { 10 10 } <baseline-gadget> 2array
1array <grid> f >>fill?
"g" set

[ ] [ "g" get prefer ] unit-test

[ { 20 15 } ] [ "g" get dim>> ] unit-test

[ V{ { 0 5 } { 10 0 } } ] [
    "g" get
    dup layout
    children>> [ loc>> ] map
] unit-test