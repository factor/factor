! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets-tracks
USING: gadgets gadgets-theme generic io kernel
math namespaces sequences words ;

TUPLE: divider ;

: divider-# ( divider -- n )
    dup gadget-parent gadget-children index 2 /i ;

: divider-size { 8 8 } ;

M: divider pref-dim* drop divider-size ;

TUPLE: track sizes saved-sizes ;

C: track ( orientation -- track )
    [ delegate>pack ] keep
    1 over set-pack-fill
    t over set-gadget-clipped? ;

: divider-sizes ( seq -- dim )
    length 1 [-] divider-size n*v ;

: track-dim ( track -- dim )
    #! Space available for content (minus dividers)
    dup rect-dim swap track-sizes divider-sizes v- ;

: track-layout ( track -- sizes )
    dup track-dim swap track-sizes
    [ [ over n*v , ] [ divider-size , ] interleave ] { } make
    nip ;

M: track layout*
    dup track-layout pack-layout ;

: track-pref-dims ( dims sizes -- dims )
    [ [ dup zero? [ nip ] [ v/n ] if ] 2map max-dim ] keep
    divider-sizes v+ [ >fixnum ] map ;

M: track pref-dim*
    [
        dup gadget-children
        2 group [ first ] map pref-dims
        dup rot track-sizes track-pref-dims >r max-dim r>
    ] keep gadget-orientation set-axis ;

: divider-delta ( track -- delta )
    #! How far the divider has moved along the track?
    drag-loc over track-dim { 1 1 } vmax v/
    swap gadget-orientation v. ;

: save-sizes ( track -- )
    dup track-sizes clone swap set-track-saved-sizes ;

: restore-sizes ( track -- )
    dup track-saved-sizes clone swap set-track-sizes ;

: set-nth-0 ( n seq -- old ) 2dup nth >r 0 -rot set-nth r> ;

: +nth ( delta n seq -- ) [ + ] change-nth ;

: clamp-nth ( i j sizes -- ) [ set-nth-0 swap ] keep +nth ;

: clamp-up? ( delta n sizes -- ? ) nth + 0 < ;

: clamp-down? ( delta n sizes -- ? ) >r 1+ r> nth swap - 0 < ;

: change-last-size ( delta n sizes -- )
    #! Its a bit simpler to resize the last divider since we
    #! don't have to adjust the next one.
    3dup clamp-up? [ set-nth-0 2drop ] [ +nth ] if ;

: change-inner-size ( delta n sizes -- )
    #! When changing a divider which isn't the last, we have to
    #! resize the next area, too.
    {
        { [ 3dup clamp-up? ] [ >r dup 1+ swap r> clamp-nth drop ] }
        { [ 3dup clamp-down? ] [ >r dup 1+ r> clamp-nth drop ] }
        { [ t ] [ pick neg pick 1+ pick +nth +nth ] }
    } cond ;

: change-size ( delta n sizes -- )
    over 1+ over length =
    [ change-last-size ] [ change-inner-size ] if ;

: change-divider ( delta n track -- )
    [ dup restore-sizes track-sizes change-size ] keep
    relayout-1 ;

: divider-motion ( divider -- )
    dup gadget-parent divider-delta
    over divider-# rot gadget-parent change-divider ;

divider H{
    { T{ button-down } [ gadget-parent save-sizes ] }
    { T{ button-up } [ drop ] }
    { T{ drag } [ divider-motion ] }
} set-gestures

C: divider ( -- divider )
    dup delegate>gadget ;

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

: track-remove@ ( n track -- )
    #! Remove the divider if this is not the last child.
    2dup nth-gadget unparent
    dup gadget-children empty? [
        2dup gadget-children length = [ >r 1- r> ] when
        2dup nth-gadget unparent
    ] unless
    [ >r 2 /i r> track-sizes remove-nth normalize-sizes ] keep
    [ set-track-sizes ] keep relayout-1 ;

: track-remove ( gadget track -- )
    [ gadget-children index ] keep track-remove@ ;

: build-track ( track specs -- )
    #! Specs is an array of quadruples { quot post setter loc }.
    #! The setter has stack effect ( new gadget -- ),
    #! the loc is a ratio from 0 to 1.
    [ swap [ [ drop track-add ] build-spec ] with-gadget ] 2keep
    [ peek ] map swap set-track-sizes ; inline

: make-track ( specs orientation -- gadget )
    <track> [ swap build-track ] keep ; inline

: make-track* ( gadget specs orientation -- gadget )
    <track> pick [ set-delegate build-track ] keep ; inline
