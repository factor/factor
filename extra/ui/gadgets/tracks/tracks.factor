! Copyright (C) 2006, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors io kernel math namespaces
sequences words math.vectors ui.gadgets ui.gadgets.packs ;
IN: ui.gadgets.tracks

TUPLE: track < pack sizes ;

: normalized-sizes ( track -- seq )
    track-sizes
    [ sift sum ] keep [ dup [ over / ] when ] map nip ;

: new-track ( orientation class -- track )
    new-gadget
        swap >>orientation
        V{ } clone >>sizes
        1 >>fill ; inline

: <track> ( orientation -- track )
    track new-track ;

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
    gadget get swap track-add ;

: make-track ( quot orientation -- track )
    <track> swap make-gadget ; inline

: track-remove ( gadget track -- )
    over [
        [ gadget-children index ] 2keep
        swap unparent track-sizes delete-nth
    ] [
        2drop
    ] if ;

: clear-track ( track -- )
    V{ } clone over set-track-sizes clear-gadget ;
