IN: temporary
USING: gadgets gadgets-scrolling namespaces test ;

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
