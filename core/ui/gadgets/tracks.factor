! Copyright (C) 2006, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets-tracks
USING: gadgets gadgets-theme gadgets-buttons generic io kernel
math namespaces sequences words ;

TUPLE: track sizes ;

: normalized-sizes ( track -- seq )
    track-sizes
    [ [ ] subset sum ] keep [ dup [ over / ] when ] map nip ;

C: track ( orientation -- track )
    [ delegate>pack ] keep
    1 over set-pack-fill
    V{ } clone over set-track-sizes ;

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

: track-add ( gadget track size -- )
    over track-sizes push add-gadget ;

: track, ( gadget size -- ) \ make-gadget get swap track-add ;

: make-track ( quot orientation -- track )
    <track> make-gadget ; inline

: build-track ( tuple quot orientation -- tuple )
    <track> build-gadget ; inline

: toolbar, ( -- ) g <toolbar> f track, ;

: track-remove ( gadget track -- )
    over [
        [ gadget-children index ] 2keep
        swap unparent track-sizes delete-nth
    ] [
        2drop
    ] if ;

: clear-track ( track -- )
    V{ } clone over set-track-sizes clear-gadget ;
