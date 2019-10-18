IN: temporary
USING: gadgets gadgets-scrolling namespaces test kernel
models gadgets-viewports math ;

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
    <gadget> dup "g" set { 10 20 } <model> <viewport> "v" set 
] unit-test

[ { 10 20 } ] [ "g" get rect-loc vneg { 3 3 } v+ ] unit-test

[ ] [
    <gadget> { 100 100 } over set-rect-dim
    dup "g" set <scroller> "s" set
] unit-test

[ ] [ "s" get graft ] unit-test

[ ] [ "s" get { 10 20 } scroll ] unit-test

[ { 10 20 } ] [ "g" get rect-loc vneg { 3 3 } v+ ] unit-test

[ ] [ "s" get ungraft ] unit-test
