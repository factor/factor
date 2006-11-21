IN: temporary
USING: gadgets test namespaces ;

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
