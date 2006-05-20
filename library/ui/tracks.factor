! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets-tracks
USING: gadgets gadgets-layouts gadgets-theme io kernel math
namespaces sequences ;

TUPLE: divider # splitter ;

: divider-size { 8 8 0 } ;

M: divider pref-dim* drop divider-size ;

TUPLE: track sizes saved-sizes ;

C: track ( orientation -- track )
    [ delegate>pack ] keep 1 over set-pack-fill ;

: track-dim ( track -- dim )
    #! Space available for content (minus dividers)
    dup rect-dim swap track-sizes length 1-
    divider-size n*v v- ;

: track-layout ( track -- sizes )
    dup track-dim swap track-sizes
    [ [ over n*v , ] [ divider-size , ] interleave ] { } make
    nip ;

M: track layout* ( splitter -- )
    dup track-layout packed-layout ;

: divider-delta ( track -- delta )
    #! How far the divider has moved along the track?
    drag-loc over track-dim { 1 1 1 } vmax v/
    swap gadget-orientation v. ;

: +nth ( delta n seq -- ) swap [ + ] change-nth ;

: save-sizes ( track -- )
    dup track-sizes clone swap set-track-saved-sizes ;

: restore-sizes ( track -- )
    dup track-saved-sizes clone swap set-track-sizes ;

: change-divider ( delta n track -- )
    [
        dup restore-sizes
        track-sizes
        [ +nth ] 3keep
        >r 1+ >r neg r> r> 2dup length = [ 3drop ] [ +nth ] if
    ] keep relayout-1 ;

: divider-motion ( divider -- )
    dup gadget-parent divider-delta
    over divider-# rot gadget-parent change-divider ;

: divider-actions ( divider -- )
    dup [ gadget-parent save-sizes ] T{ button-down } set-action
    dup [ drop ] T{ button-up } set-action
    [ divider-motion ] T{ drag } set-action ;

C: divider ( n -- divider )
    [ set-divider-# ] keep
    dup delegate>gadget
    dup divider-actions
    dup reverse-video-theme ;

: normalize-sizes ( sizes -- sizes )
    dup sum swap [ swap / ] map-with ;

: track-add-size ( sizes -- sizes )
    dup length 1 max recip add normalize-sizes ;

: add-divider ( track -- )
    dup track-sizes length dup zero?
    [ 2drop ] [ 1- <divider> swap add-gadget ] if ;

: track-add ( gadget track -- )
    dup add-divider [ add-gadget ] keep
    dup track-sizes track-add-size swap set-track-sizes ;

: track-remove ( gadget track -- )
    ! wrong
    [ gadget-children index ] 2keep swap unparent
    [ remove-index ] keep set-track-sizes ;
