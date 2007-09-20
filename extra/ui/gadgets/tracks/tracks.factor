! Copyright (C) 2006, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: ui.gadgets ui.gadgets.packs io kernel math namespaces
sequences words math.vectors ;
IN: ui.gadgets.tracks

TUPLE: track sizes ;

: normalized-sizes ( track -- seq )
    track-sizes
    [ [ ] subset sum ] keep [ dup [ over / ] when ] map nip ;

: <track> ( orientation -- track )
    <pack> V{ } clone
    { set-delegate set-track-sizes } track construct
    1 over set-pack-fill ;

: alloted-dim ( track -- dim )
    dup gadget-children swap track-sizes { 0 0 }
    [ [ drop { 0 0 } ] [ pref-dim ] if v+ ] 2reduce ;

: available-dim ( track -- dim )
    dup rect-dim swap alloted-dim v- ;

: track-layout ( track -- sizes )
    dup available-dim over gadget-children rot normalized-sizes
    [ [ over n*v ] [ pref-dim ] ?if ] 2map nip ;

M: track layout*
    dup track-layout pack-layout ;

: track-pref-dims-1 ( track -- dim )
    gadget-children pref-dims max-dim ;

: track-pref-dims-2 ( track -- dim )
    dup gadget-children pref-dims swap normalized-sizes
    [ [ v/n ] when* ] 2map max-dim [ >fixnum ] map ;

M: track pref-dim*
    dup track-pref-dims-1
    over alloted-dim
    pick track-pref-dims-2 v+
    rot gadget-orientation set-axis ;

: track-add ( gadget track constraint -- )
    over track-sizes push add-gadget ;

: track, ( gadget constraint -- )
    \ make-gadget get swap track-add ;

: make-track ( quot orientation -- track )
    <track> make-gadget ; inline

: build-track ( tuple quot orientation -- tuple )
    <track> build-gadget ; inline

: track-remove ( gadget track -- )
    over [
        [ gadget-children index ] 2keep
        swap unparent track-sizes delete-nth
    ] [
        2drop
    ] if ;

: clear-track ( track -- )
    V{ } clone over set-track-sizes clear-gadget ;
