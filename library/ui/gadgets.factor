! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: generic hashtables kernel lists math namespaces ;

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

: ?move ( x y gadget quot -- )
    >r 3dup shape-pos >r rect> r> = [
        3drop
    ] r> ifte ; inline

: move-gadget ( x y gadget -- )
    [ [ move-shape ] keep redraw ] ?move ;

: ?resize ( w h gadget quot -- )
    >r 3dup shape-size rect> >r rect> r> = [
        3drop
    ] r> ifte ; inline

: resize-gadget ( w h gadget -- )
    [ [ resize-shape ] keep relayout* ] ?resize ;

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

GENERIC: layout* ( gadget -- )

: prefer ( gadget -- ) [ pref-size ] keep resize-gadget ;

M: gadget layout*
    #! Trivial layout gives each child its preferred size.
    gadget-children [ prefer ] each ;

GENERIC: user-input* ( ch gadget -- ? )
M: gadget user-input* 2drop t ;
