IN: temporary
USING: ui.gadgets ui.gadgets.packs ui.gadgets.worlds tools.test
namespaces models kernel ;

[ T{ rect f { 10 10 } { 20 20 } } ]
[
    T{ rect f { 10 10 } { 50 50 } }
    T{ rect f { -10 -10 } { 40 40 } }
    rect-intersect
] unit-test

[ T{ rect f { 200 200 } { 0 0 } } ]
[
    T{ rect f { 100 100 } { 50 50 } }
    T{ rect f { 200 200 } { 40 40 } }
    rect-intersect
] unit-test

[ f ] [
    T{ rect f { 100 100 } { 50 50 } }
    T{ rect f { 200 200 } { 40 40 } }
    intersects?
] unit-test

[ t ] [
    T{ rect f { 100 100 } { 50 50 } }
    T{ rect f { 120 120 } { 40 40 } }
    intersects?
] unit-test

[ f ] [
    T{ rect f { 1000 100 } { 50 50 } }
    T{ rect f { 120 120 } { 40 40 } }
    intersects?
] unit-test

TUPLE: fooey ;

C: <fooey> fooey

[ ] [ <gadget> <fooey> set-gadget-delegate ] unit-test
[ ] [ f <fooey> set-gadget-delegate ] unit-test

[ { 300 300 } ]
[
    ! c contains b contains a
    <gadget> "a" set
    <gadget> "b" set
    "a" get "b" get add-gadget
    <gadget> "c" set
    "b" get "c" get add-gadget
    
    ! position a and b
    { 100 200 } "a" get set-rect-loc
    { 200 100 } "b" get set-rect-loc
    
    ! give c a loc, it doesn't matter
    { -1000 23 } "c" get set-rect-loc

    ! what is the location of a inside c?
    "a" get "c" get relative-loc
] unit-test

<gadget> "g1" set
{ 10 10 } "g1" get set-rect-loc
{ 30 30 } "g1" get set-rect-dim
<gadget> "g2" set
{ 20 20 } "g2" get set-rect-loc
{ 50 500 } "g2" get set-rect-dim
<gadget> "g3" set
{ 100 200 } "g3" get set-rect-dim

"g1" get "g2" get add-gadget
"g2" get "g3" get add-gadget

[ { 30 30 } ] [ "g1" get screen-loc ] unit-test
[ { 30 30 } ] [ "g1" get screen-rect rect-loc ] unit-test
[ { 30 30 } ] [ "g1" get screen-rect rect-dim ] unit-test
[ { 20 20 } ] [ "g2" get screen-loc ] unit-test
[ { 20 20 } ] [ "g2" get screen-rect rect-loc ] unit-test
[ { 50 180 } ] [ "g2" get screen-rect rect-dim ] unit-test
[ { 0 0 } ] [ "g3" get screen-loc ] unit-test
[ { 0 0 } ] [ "g3" get screen-rect rect-loc ] unit-test
[ { 100 200 } ] [ "g3" get screen-rect rect-dim ] unit-test

<gadget> "g1" set
{ 300 300 } "g1" get set-rect-dim
<gadget> "g2" set
"g2" get "g1" get add-gadget
{ 20 20 } "g2" get set-rect-loc
{ 20 20 } "g2" get set-rect-dim
<gadget> "g3" set
"g3" get "g1" get add-gadget
{ 100 100 } "g3" get set-rect-loc
{ 20 20 } "g3" get set-rect-dim

[ t ] [ { 30 30 } "g2" get inside? ] unit-test

[ t ] [ { 30 30 } "g1" get (pick-up) "g2" get eq? ] unit-test

[ t ] [ { 30 30 } "g1" get pick-up "g2" get eq? ] unit-test

[ t ] [ { 110 110 } "g1" get pick-up "g3" get eq? ] unit-test

<gadget> "g4" set
"g4" get "g2" get add-gadget
{ 5 5 } "g4" get set-rect-loc
{ 1 1 } "g4" get set-rect-dim

[ t ] [ { 25 25 } "g1" get pick-up "g4" get eq? ] unit-test
