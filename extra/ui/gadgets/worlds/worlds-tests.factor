IN: temporary
USING: ui.gadgets ui.gadgets.packs ui.gadgets.worlds tools.test
namespaces models kernel ;

! Test focus behavior
<gadget> "g1" set

: <test-world> ( gadget -- world )
    [ gadget, ] make-pile "Hi" f <world> ;

[ ] [
    "g1" get <test-world> "w" set
] unit-test

[ ] [ "g1" get request-focus ] unit-test

[ t ] [ "w" get gadget-focus "g1" get eq? ] unit-test

<gadget> "g1" set
<gadget> "g2" set
"g1" get "g2" get add-gadget

[ ] [
    "g2" get <test-world> "w" set
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
    "g3" get <test-world> "w" set
] unit-test

[ ] [ "g1" get request-focus ] unit-test
[ ] [ "g2" get unparent ] unit-test
[ t ] [ "g3" get gadget-focus "g1" get eq? ] unit-test

[ t ] [ <gadget> dup <test-world> focusable-child eq? ] unit-test

TUPLE: focusing ;

: <focusing>
    focusing construct-gadget ;

TUPLE: focus-test ;

: <focus-test>
    focus-test construct-gadget
    <focusing> over add-gadget ;

M: focus-test focusable-child* gadget-child ;

<focus-test> "f" set

[ ] [ "f" get <test-world> request-focus ] unit-test

[ t ] [ "f" get gadget-focus "f" get gadget-child eq? ] unit-test

[ t ] [ "f" get gadget-child focusing? ] unit-test
