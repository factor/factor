USING: ui.gadgets ui.gadgets.packs ui.gadgets.worlds tools.test
namespaces models kernel accessors arrays ;
IN: ui.gadgets.worlds.tests

! Test focus behavior
<gadget> "g1" set

: <test-world> ( gadget -- world )
    <world-attributes> "Hi" >>title swap 1array >>gadgets <world> ;

[ ] [
    "g1" get <test-world> "w" set
] unit-test

[ ] [ "g1" get request-focus ] unit-test

[ t ] [ "w" get focus>> "g1" get eq? ] unit-test

<gadget> "g1" set
<gadget> "g2" set
"g2" get "g1" get add-gadget drop

[ ] [
    "g2" get <test-world> "w" set
] unit-test

[ ] [ "g1" get request-focus ] unit-test

[ t ] [ "w" get focus>> "g2" get eq? ] unit-test
[ t ] [ "g2" get focus>> "g1" get eq? ] unit-test
[ f ] [ "g1" get focus>> ] unit-test

<gadget> "g1" set
<gadget> "g2" set
<gadget> "g3" set
"g3" get "g1" get add-gadget drop
"g3" get "g2" get add-gadget drop

[ ] [
    "g3" get <test-world> "w" set
] unit-test

[ ] [ "g1" get request-focus ] unit-test
[ ] [ "g2" get unparent ] unit-test
[ t ] [ "g3" get focus>> "g1" get eq? ] unit-test

[ t ] [ <gadget> dup <test-world> focusable-child eq? ] unit-test

TUPLE: focusing < gadget ;

: <focusing> ( -- gadget ) focusing new ;

TUPLE: focus-test < gadget ;

: <focus-test> ( -- gadget )
    focus-test new <focusing> add-gadget ;

M: focus-test focusable-child* gadget-child ;

<focus-test> "f" set

[ ] [ "f" get <test-world> request-focus ] unit-test

[ t ] [ "f" get focus>> "f" get gadget-child eq? ] unit-test

[ t ] [ "f" get gadget-child focusing? ] unit-test
