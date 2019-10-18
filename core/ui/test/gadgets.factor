IN: temporary
USING: gadgets test namespaces models kernel ;

TUPLE: fooey ;

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

! Test focus behavior
<gadget> "g1" set

[ ] [
    "g1" get <gadget> f <model> "Hi" <world> "w" set
] unit-test

[ ] [ "g1" get request-focus ] unit-test

[ t ] [ "w" get gadget-focus "g1" get eq? ] unit-test

<gadget> "g1" set
<gadget> "g2" set
"g1" get "g2" get add-gadget

[ ] [
    "g2" get <gadget> f <model> "Hi" <world> "w" set
] unit-test

[ ] [ "g1" get request-focus ] unit-test

[ t ] [ "w" get gadget-focus "g2" get eq? ] unit-test
[ t ] [ "g2" get gadget-focus "g1" get eq? ] unit-test
[ f ] [ "g1" get gadget-focus ] unit-test

<gadget> "g1" set
<gadget> "g2" set
<gadget> "g3" set
"g1" get "g3" get add-gadget
"g2" get "g3" get add-gadget

[ ] [
    "g3" get <gadget> f <model> "Hi" <world> "w" set
] unit-test

[ ] [ "g1" get request-focus ] unit-test
[ ] [ "g2" get unparent ] unit-test
[ t ] [ "g3" get gadget-focus "g1" get eq? ] unit-test

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
