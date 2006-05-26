! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets-tracks
USING: gadgets gadgets-layouts gadgets-theme generic io kernel
math namespaces sequences words ;

TUPLE: divider ;

: divider-# ( divider -- n )
    dup gadget-parent gadget-children index 2 /i ;

: divider-size { 8 8 0 } ;

M: divider pref-dim* drop divider-size ;

TUPLE: track sizes saved-sizes ;

C: track ( orientation -- track )
    [ delegate>pack ] keep 1 over set-pack-fill ;

: <x-track> { 0 1 0 } <track> ;

: <y-track> { 1 0 0 } <track> ;

: divider-sizes ( seq -- dim )
    length 1- 0 max divider-size n*v ;

: track-dim ( track -- dim )
    #! Space available for content (minus dividers)
    dup rect-dim swap track-sizes divider-sizes v- ;

: track-layout ( track -- sizes )
    dup track-dim swap track-sizes
    [ [ over n*v , ] [ divider-size , ] interleave ] { } make
    nip ;

M: track layout* ( track -- )
    dup track-layout packed-layout ;

: track-pref-dims ( dims sizes -- dims )
    [ [ dup zero? [ nip ] [ v/n ] if ] 2map max-dim ] keep
    divider-sizes v+ ;

M: track pref-dim* ( track -- dim )
    [
        dup gadget-children
        2 swap group [ first ] map pref-dims
        dup rot track-sizes track-pref-dims >r max-dim r>
    ] keep gadget-orientation set-axis ;

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

C: divider ( -- divider )
    dup delegate>gadget
    dup divider-actions
    dup reverse-video-theme ;

: normalize-sizes ( sizes -- sizes )
    dup sum swap [ swap / ] map-with ;

: track-add-size ( sizes -- sizes )
    dup length 1 max recip add normalize-sizes ;

: add-divider ( track -- )
    dup track-sizes empty?
    [ drop ] [ <divider> swap add-gadget ] if ;

: track-add ( gadget track -- )
    dup add-divider [ add-gadget ] keep
    dup track-sizes track-add-size swap set-track-sizes ;

: nth-gadget gadget-children nth ;

: track-remove@ ( n track -- )
    #! Remove the divider if this is not the last child.
    2dup nth-gadget unparent
    dup gadget-children empty? [
        2dup gadget-children length = [ >r 1- r> ] when
        2dup nth-gadget unparent
    ] unless
    [ >r 2 /i r> track-sizes remove-index normalize-sizes ] keep
    [ set-track-sizes ] keep relayout-1 ;

: track-remove ( gadget track -- )
    [ gadget-children index ] keep track-remove@ ;

: track-add-spec ( { quot setter loc } -- )
    first2
    >r call track get 2dup track-add
    r> dup [ execute ] [ 3drop ] if ;

: build-track ( track specs -- )
    #! Specs is an array of triples { quot setter loc }.
    #! The setter has stack effect ( new gadget -- ),
    #! the loc is a ratio from 0 to 1.
    [
        swap track set
        [ [ track-add-spec ] each ] keep
        [ third ] map track get set-track-sizes
    ] with-scope ;

: make-track ( specs orientation -- gadget )
    <track> [ swap build-track ] keep ;

: make-track* ( gadget specs orientation -- gadget )
    <track> pick [ set-delegate build-track ] keep ;
