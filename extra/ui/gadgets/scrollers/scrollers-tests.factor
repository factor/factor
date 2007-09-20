IN: temporary
USING: ui.gadgets ui.gadgets.scrollers ui.gadgets.controls
namespaces tools.test kernel models ui.gadgets.viewports math
math.vectors arrays sequences ;

[ ] [
    <gadget> "g" set
    "g" get <scroller> "s" set
] unit-test

[ { 100 200 } ] [
    { 100 200 } "g" get scroll>rect
    "s" get scroller-follows rect-loc
] unit-test

[ ] [ "s" get scroll>bottom ] unit-test
[ t ] [ "s" get scroller-follows ] unit-test

[ ] [
    <gadget> dup "g" set
    10 1 0 100 <range> 20 1 0 100 <range> 2array <compose>
    <viewport> "v" set 
] unit-test

[ { 10 20 } ] [ "v" get control-model range-value ] unit-test

[ { 10 20 } ] [ "g" get rect-loc vneg { 3 3 } v+ ] unit-test

[ ] [
    <gadget> { 100 100 } over set-rect-dim
    dup "g" set <scroller> "s" set
] unit-test

[ ] [ { 50 50 } "s" get set-rect-dim ] unit-test

[ ] [ "s" get layout ] unit-test

[ ] [ "s" get graft ] unit-test

[ { 34 34 } ] [ "s" get scroller-viewport rect-dim ] unit-test

[ { 106 106 } ] [ "s" get scroller-viewport viewport-dim ] unit-test

[ ] [ { 0 0 } "s" get scroll ] unit-test

[ { 0 0 } ] [ "s" get control-model range-min-value ] unit-test

[ { 106 106 } ] [ "s" get control-model range-max-value ] unit-test

[ ] [ { 10 20 } "s" get scroll ] unit-test

[ { 10 20 } ] [ "s" get control-model range-value ] unit-test

[ { 10 20 } ] [ "s" get scroller-viewport control-model range-value ] unit-test

[ { 10 20 } ] [ "g" get rect-loc vneg { 3 3 } v+ ] unit-test

[ ] [ "s" get ungraft ] unit-test

<gadget> { 600 400 } over set-rect-dim "g1" set
<gadget> { 600 10 } over set-rect-dim "g2" set
"g2" get "g1" get add-gadget

"g1" get <scroller>
{ 300 300 } over set-rect-dim
dup layout
"s" set

[ t ] [
    10 [
        drop
        "g2" get scroll>gadget
        "s" get layout
        "s" get scroller-value
    ] map [ { 3 0 } = ] all?
] unit-test
