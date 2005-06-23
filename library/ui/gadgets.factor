! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: generic hashtables kernel lists math namespaces sequences
vectors ;

! A gadget is a shape, a paint, a mapping of gestures to
! actions, and a reference to the gadget's parent. A gadget
! delegates to its shape.
TUPLE: gadget paint gestures relayout? redraw? parent children ;

C: gadget ( shape -- gadget )
    [ set-delegate ] keep
    [ <namespace> swap set-gadget-paint ] keep
    [ <namespace> swap set-gadget-gestures ] keep
    [ t swap set-gadget-relayout? ] keep
    [ t swap set-gadget-redraw? ] keep ;

: <empty-gadget> ( -- gadget ) 0 0 0 0 <rectangle> <gadget> ;

: <plain-gadget> ( -- gadget ) 0 0 0 0 <plain-rect> <gadget> ;

: redraw ( gadget -- )
    #! Redraw a gadget before the next iteration of the event
    #! loop.
    dup gadget-redraw? [
        drop
    ] [
        t over set-gadget-redraw?
        gadget-parent [ redraw ] when*
    ] ifte ;

: relayout ( gadget -- )
    #! Relayout and redraw a gadget and its parent before the
    #! next iteration of the event loop.
    dup gadget-relayout? [
        drop
    ] [
        t over set-gadget-redraw?
        t over set-gadget-relayout?
        gadget-parent [ relayout ] when*
    ] ifte ;

: relayout* ( gadget -- )
    #! Relayout a gadget and its children.
    dup relayout gadget-children [ relayout* ] each ;

: set-gadget-loc ( loc gadget -- )
    2dup shape-loc =
    [ 2drop ] [ [ set-shape-loc ] keep redraw ] ifte ;

: move-gadget ( x y gadget -- )
    >r 0 3vector r> set-gadget-loc ;

: set-gadget-dim ( dim gadget -- )
    2dup shape-dim =
    [ 2drop ] [ [ set-shape-dim ] keep relayout* ] ifte ;

: resize-gadget ( w h gadget -- )
    >r 0 3vector r> set-gadget-dim ;

: paint-prop ( gadget key -- value )
    over [
        dup pick gadget-paint hash* dup [
            2nip cdr
        ] [
            drop >r gadget-parent r> paint-prop
        ] ?ifte
    ] [
        2drop f
    ] ifte ;

: set-paint-prop ( gadget value key -- )
    rot gadget-paint set-hash ;

GENERIC: pref-size ( gadget -- w h )

M: gadget pref-size shape-size ;

: pref-dim pref-size 0 3vector ;

GENERIC: layout* ( gadget -- )

: prefer ( gadget -- ) [ pref-size ] keep resize-gadget ;

M: gadget layout*
    #! Trivial layout gives each child its preferred size.
    gadget-children [ prefer ] each ;

GENERIC: user-input* ( ch gadget -- ? )
M: gadget user-input* 2drop t ;
