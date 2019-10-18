IN: temporary
USING: gadgets-tracks gadgets test kernel namespaces math
sequences ;

[ { 1/3 1/2 1/6 } ] [
    { 1/3 1/2 1/6 } track-add-size 1 head* normalize-sizes
] unit-test

{
    {
        [ <gadget> { 100 200 } over set-rect-dim ]
        f
        f
        1/2
    }
    {
        [ <gadget> { 100 100 } over set-rect-dim ]
        f
        f
        1/4
    }
    {
        [ <gadget> { 100 100 } over set-rect-dim ]
        f
        f
        1/4
    }
} { 0 1 } make-track "track" set

"track" get dup prefer layout

[ { 100 416 } ] [ "track" get rect-dim ] unit-test

[ V{ { 100 200 } { 100 8 } { 100 100 } { 100 8 } { 100 100 } } ]
[ "track" get gadget-children [ rect-dim ] map ] unit-test

[ { 1/2 1/4 1/4 } ] [ "track" get track-sizes ] unit-test

<gadget> { 70 70 } over set-rect-dim "track" get track-add
"track" get layout
[ { 3/8 3/16 3/16 1/4 } ] [ "track" get track-sizes ] unit-test

"track" get [ gadget-children length 1- ] keep track-remove@
"track" get layout
[ { 1/2 1/4 1/4 } ] [ "track" get track-sizes ] unit-test

[ V{ { 100 200 } { 100 8 } { 100 100 } { 100 8 } { 100 100 } } ]
[ "track" get gadget-children [ rect-dim ] map ] unit-test
