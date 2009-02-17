! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel accessors sequences ui ui.gadgets ui.gadgets.buttons
ui.baseline-alignment ui.render ;
IN: ui.gadgets.debug

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
