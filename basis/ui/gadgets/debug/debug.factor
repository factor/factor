! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel accessors ui ui.gadgets ui.gadgets.buttons ui.render ;
IN: ui.gadgets.debug

TUPLE: baseline-gadget < gadget baseline ;

M: baseline-gadget baseline baseline>> ;

: <baseline-gadget> ( baseline dim -- gadget )
    baseline-gadget new
        swap >>dim
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
