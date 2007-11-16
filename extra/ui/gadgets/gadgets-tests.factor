IN: temporary
USING: ui.gadgets ui.gadgets.packs ui.gadgets.worlds tools.test
namespaces models kernel tools.test.inference dlists math
math.parser ui sequences hashtables assocs io arrays
prettyprint io.streams.string ;

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

TUPLE: mock-gadget graft-called ungraft-called ;

: <mock-gadget>
    0 0 mock-gadget construct-boa <gadget> over set-delegate ;

M: mock-gadget graft*
    dup mock-gadget-graft-called 1+
    swap set-mock-gadget-graft-called ;

M: mock-gadget ungraft*
    dup mock-gadget-ungraft-called 1+
    swap set-mock-gadget-ungraft-called ;

! We can't print to stdio here because that might be a pane
! stream, and our graft-queue rebinding here would be captured
! by code adding children to the pane...
[
    <dlist> \ graft-queue [
        [ ] [ <mock-gadget> dup queue-graft unqueue-graft ] unit-test
        [ t ] [ graft-queue dlist-empty? ] unit-test
    ] with-variable

    <dlist> \ graft-queue [
        [ t ] [ graft-queue dlist-empty? ] unit-test

        <mock-gadget> "g" set
        [ ] [ "g" get queue-graft ] unit-test
        [ f ] [ graft-queue dlist-empty? ] unit-test
        [ { f t } ] [ "g" get gadget-status ] unit-test
        [ ] [ "g" get graft-later ] unit-test
        [ { f t } ] [ "g" get gadget-status ] unit-test
        [ ] [ "g" get ungraft-later ] unit-test
        [ { f f } ] [ "g" get gadget-status ] unit-test
        [ t ] [ graft-queue dlist-empty? ] unit-test
        [ ] [ "g" get ungraft-later ] unit-test
        [ ] [ "g" get graft-later ] unit-test
        [ ] [ notify-queued ] unit-test
        [ { t t } ] [ "g" get gadget-status ] unit-test
        [ t ] [ graft-queue dlist-empty? ] unit-test
        [ ] [ "g" get graft-later ] unit-test
        [ 1 ] [ "g" get mock-gadget-graft-called ] unit-test
        [ ] [ "g" get ungraft-later ] unit-test
        [ { t f } ] [ "g" get gadget-status ] unit-test
        [ ] [ notify-queued ] unit-test
        [ 1 ] [ "g" get mock-gadget-ungraft-called ] unit-test
        [ { f f } ] [ "g" get gadget-status ] unit-test
    ] with-variable

    : add-some-children
        3 [
            <mock-gadget> over <model> over set-gadget-model
            dup "g" get add-gadget
            swap 1+ number>string set
        ] each ;

    : status-flags
        { "g" "1" "2" "3" } [ get gadget-status ] map prune ;

    : notify-combo ( ? ? -- )
        nl "===== Combo: " write 2dup 2array . nl
        <dlist> \ graft-queue [
            <mock-gadget> "g" set
            [ ] [ add-some-children ] unit-test
            [ V{ { f f } } ] [ status-flags ] unit-test
            [ ] [ "g" get graft ] unit-test
            [ V{ { f t } } ] [ status-flags ] unit-test
            dup [ [ ] [ notify-queued ] unit-test ] when
            [ ] [ "g" get clear-gadget ] unit-test
            [ [ 1 ] [ graft-queue dlist-length ] unit-test ] unless
            [ [ ] [ notify-queued ] unit-test ] when
            [ ] [ add-some-children ] unit-test
            [ { f t } ] [ "1" get gadget-status ] unit-test
            [ { f t } ] [ "2" get gadget-status ] unit-test
            [ { f t } ] [ "3" get gadget-status ] unit-test
            [ ] [ [ "x" print notify ] graft-queue swap dlist-slurp ] unit-test
            [ ] [ notify-queued ] unit-test
            [ V{ { t t } } ] [ status-flags ] unit-test
        ] with-variable ;

    { { f f } { f t } { t f } { t t } } [ notify-combo ] assoc-each
] string-out print

{ 0 1 } [ <gadget> ] unit-test-effect
{ 1 0 } [ unparent ] unit-test-effect
{ 2 0 } [ add-gadget ] unit-test-effect
{ 2 0 } [ add-gadgets ] unit-test-effect
{ 1 0 } [ clear-gadget ] unit-test-effect

{ 1 0 } [ relayout ] unit-test-effect
{ 1 0 } [ relayout-1 ] unit-test-effect
{ 1 1 } [ pref-dim ] unit-test-effect
