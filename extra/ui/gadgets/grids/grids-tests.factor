USING: ui.gadgets ui.gadgets.grids tools.test kernel arrays
namespaces ;
IN: temporary

[ { 0 0 } ] [ { } <grid> pref-dim ] unit-test

: 100x100 <gadget> { 100 100 } over set-rect-dim ;

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
    [ 1array ] 2apply 2array <grid> pref-dim
] unit-test

[ ] [
    100x100
    100x100
    [ 1array ] 2apply 2array <grid> layout
] unit-test

[ { 230 120 } { 100 100 } { 100 100 } ] [
    100x100 dup "a" set
    100x100 dup "b" set
    2array 1array <grid>
    { 10 10 } over set-grid-gap
    dup prefer
    dup layout
    rect-dim
    "a" get rect-dim
    "b" get rect-dim
] unit-test
