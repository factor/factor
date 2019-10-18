! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets-tracks
USING: gadgets gadgets-theme generic io kernel
math namespaces sequences words ;

TUPLE: track sizes ;

C: track ( orientation -- track )
    [ delegate>pack ] keep
    1 over set-pack-fill
    V{ } clone over set-track-sizes ;

: track-layout ( track -- sizes )
    dup rect-dim swap track-sizes [ v*n ] map-with ;

M: track layout*
    dup track-layout pack-layout ;

: track-pref-dims ( dims sizes -- dim )
    [ v/n ] 2map max-dim [ >fixnum ] map ;

M: track pref-dim*
    [
        dup gadget-children pref-dims
        dup rot track-sizes track-pref-dims >r max-dim r>
    ] keep gadget-orientation set-axis ;

: track-add ( gadget track size -- )
    over track-sizes push add-gadget ;

: build-track ( track specs -- )
    swap [ [ track-add ] build-spec ] with-gadget ; inline

: make-track ( specs orientation -- gadget )
    <track> [ swap build-track ] keep ; inline

: make-track* ( gadget specs orientation -- gadget )
    <track> pick [ set-delegate build-track ] keep ; inline
