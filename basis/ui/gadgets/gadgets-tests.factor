USING: accessors ui.gadgets ui.gadgets.private ui.gadgets.packs
ui.gadgets.worlds tools.test namespaces models kernel dlists deques
math sets math.parser ui sequences hashtables assocs io arrays
prettyprint io.streams.string math.rectangles ui.gadgets.private
sets generic ;
IN: ui.gadgets.tests

[ { 300 300 } ]
[
    ! c contains b contains a
    <gadget> "a" set
    <gadget> "b" set
    "b" get "a" get add-gadget drop
    <gadget> "c" set
    "c" get "b" get add-gadget drop

    ! position a and b
    "a" get { 100 200 } >>loc drop
    "b" get { 200 100 } >>loc drop

    ! give c a loc, it doesn't matter
    "c" get { -1000 23 } >>loc drop

    ! what is the location of a inside c?
    "a" get "c" get relative-loc
] unit-test

<gadget> "g1" set
"g1" get { 10 10 } >>loc
         { 30 30 } >>dim drop
<gadget> "g2" set
"g2" get { 20 20 } >>loc
         { 50 500 } >>dim drop
<gadget> "g3" set
"g3" get { 100 200 } >>dim drop

"g2" get "g1" get add-gadget drop
"g3" get "g2" get add-gadget drop

[ { 30 30 } ] [ "g1" get screen-loc ] unit-test
[ { 30 30 } ] [ "g1" get screen-rect loc>> ] unit-test
[ { 30 30 } ] [ "g1" get screen-rect dim>> ] unit-test
[ { 20 20 } ] [ "g2" get screen-loc ] unit-test
[ { 20 20 } ] [ "g2" get screen-rect loc>> ] unit-test
[ { 50 180 } ] [ "g2" get screen-rect dim>> ] unit-test
[ { 0 0 } ] [ "g3" get screen-loc ] unit-test
[ { 0 0 } ] [ "g3" get screen-rect loc>> ] unit-test
[ { 100 200 } ] [ "g3" get screen-rect dim>> ] unit-test

<gadget> "g1" set
"g1" get { 300 300 } >>dim drop
<gadget> "g2" set
"g1" get "g2" get add-gadget drop
"g2" get { 20 20 } >>loc
         { 20 20 } >>dim drop
<gadget> "g3" set
"g1" get "g3" get add-gadget drop
"g3" get { 100 100 } >>loc
         { 20 20 } >>dim drop

[ t ] [ { 30 30 } "g2" get contains-point? ] unit-test

[ t ] [ { 30 30 } "g1" get pick-up "g2" get eq? ] unit-test

[ t ] [ { 30 30 } "g1" get pick-up "g2" get eq? ] unit-test

[ t ] [ { 110 110 } "g1" get pick-up "g3" get eq? ] unit-test

<gadget> "g4" set
"g2" get "g4" get add-gadget drop
"g4" get { 5 5 } >>loc
         { 1 1 } >>dim drop

[ t ] [ { 25 25 } "g1" get pick-up "g4" get eq? ] unit-test

TUPLE: mock-gadget < gadget graft-called ungraft-called ;

: <mock-gadget> ( -- gadget )
    mock-gadget new 0 >>graft-called 0 >>ungraft-called ;

M: mock-gadget graft*
    [ 1+ ] change-graft-called drop ;

M: mock-gadget ungraft*
    [ 1+ ] change-ungraft-called drop ;

! We can't print to output-stream here because that might be a pane
! stream, and our graft-queue rebinding here would be captured
! by code adding children to the pane...
[
    <dlist> \ graft-queue [
        [ ] [ <mock-gadget> dup queue-graft unqueue-graft ] unit-test
        [ t ] [ graft-queue deque-empty? ] unit-test
    ] with-variable

    <dlist> \ graft-queue [
        [ t ] [ graft-queue deque-empty? ] unit-test

        <mock-gadget> "g" set
        [ ] [ "g" get queue-graft ] unit-test
        [ f ] [ graft-queue deque-empty? ] unit-test
        [ { f t } ] [ "g" get graft-state>> ] unit-test
        [ ] [ "g" get graft-later ] unit-test
        [ { f t } ] [ "g" get graft-state>> ] unit-test
        [ ] [ "g" get ungraft-later ] unit-test
        [ { f f } ] [ "g" get graft-state>> ] unit-test
        [ t ] [ graft-queue deque-empty? ] unit-test
        [ ] [ "g" get ungraft-later ] unit-test
        [ ] [ "g" get graft-later ] unit-test
        [ ] [ notify-queued ] unit-test
        [ { t t } ] [ "g" get graft-state>> ] unit-test
        [ t ] [ graft-queue deque-empty? ] unit-test
        [ ] [ "g" get graft-later ] unit-test
        [ 1 ] [ "g" get graft-called>> ] unit-test
        [ ] [ "g" get ungraft-later ] unit-test
        [ { t f } ] [ "g" get graft-state>> ] unit-test
        [ ] [ notify-queued ] unit-test
        [ 1 ] [ "g" get ungraft-called>> ] unit-test
        [ { f f } ] [ "g" get graft-state>> ] unit-test
    ] with-variable

    : add-some-children ( gadget -- gadget )
        3 [
            <mock-gadget> over <model> >>model
            "g" get over add-gadget drop
            swap 1+ number>string set
        ] each ;

    : status-flags ( -- seq )
        { "g" "1" "2" "3" } [ get graft-state>> ] map prune ;

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
            [ [ t ] [ graft-queue [ front>> ] [ back>> ] bi eq? ] unit-test ] unless
            [ [ ] [ notify-queued ] unit-test ] when
            [ ] [ add-some-children ] unit-test
            [ { f t } ] [ "1" get graft-state>> ] unit-test
            [ { f t } ] [ "2" get graft-state>> ] unit-test
            [ { f t } ] [ "3" get graft-state>> ] unit-test
            [ ] [ graft-queue [ "x" print notify ] slurp-deque ] unit-test
            [ ] [ notify-queued ] unit-test
            [ V{ { t t } } ] [ status-flags ] unit-test
        ] with-variable ;

    { { f f } { f t } { t f } { t t } } [ notify-combo ] assoc-each
] with-string-writer print

\ <gadget> must-infer
\ unparent must-infer
\ add-gadget must-infer
\ add-gadgets must-infer
\ clear-gadget must-infer

\ relayout must-infer
\ relayout-1 must-infer
\ pref-dim must-infer

\ graft* must-infer
\ ungraft* must-infer