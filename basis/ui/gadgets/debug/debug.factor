! Copyright (C) 2008, 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays colors dlists io io.streams.string
kernel namespaces opengl sequences ui ui.baseline-alignment ui.gadgets
ui.gadgets.buttons ui.gadgets.labels ui.gadgets.private ui.pens
ui.render ui.text vectors ;
IN: ui.gadgets.debug

! We can't print to output-stream here because that might be a pane
! stream, and our graft-queue rebinding here would be captured
! by code adding children to the pane...
: with-grafted-gadget ( gadget quot -- )
    [
        <dlist> \ graft-queue set
        100 <vector> \ layout-queue set
        over
        graft notify-queued
        dip
        ungraft notify-queued
    ] with-string-writer print ; inline

TUPLE: baseline-gadget < gadget baseline cap-height ;

M: baseline-gadget baseline baseline>> ;

M: baseline-gadget cap-height cap-height>> ;

: <baseline-gadget> ( baseline cap-height dim -- gadget )
    baseline-gadget new
        swap >>dim
        swap >>cap-height
        swap >>baseline ;

! An intentionally broken gadget -- used to test UI error handling,
! make sure that one bad gadget doesn't bring the whole system down

: <bad-button> ( -- button )
    "Click me if you dare"
    [ "Haha" throw ]
    <border-button> ;

TUPLE: bad-gadget < gadget ;

M: bad-gadget draw-gadget* "Lulz" throw ;

M: bad-gadget pref-dim* drop { 100 100 } ;

: <bad-gadget> ( -- gadget ) bad-gadget new ;

: bad-gadget-test ( -- )
    <bad-button> "Test 1" open-window
    <bad-gadget> "Test 2" open-window ;

SINGLETON: metrics-paint

M: metrics-paint draw-boundary
    drop
    COLOR: red gl-color
    [ dim>> ] [ >label< line-metrics ] bi
    [ [ first ] [ ascent>> ] bi* [ nip 0 swap 2array ] [ 2array ] 2bi gl-line ]
    [ drop { 0 0 } swap gl-rect ]
    2bi ;

: <metrics-gadget> ( text font -- gadget )
    [ <label> ] dip >>font metrics-paint >>boundary ;
