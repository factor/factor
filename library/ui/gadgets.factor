! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: generic hashtables kernel lists math namespaces ;

! A gadget is a shape, a paint, a mapping of gestures to
! actions, and a reference to the gadget's parent. A gadget
! delegates to its shape.
TUPLE: gadget
    paint gestures
    relayout? redraw?
    parent children delegate ;

C: gadget ( shape -- gadget )
    [ set-gadget-delegate ] keep
    [ <namespace> swap set-gadget-paint ] keep
    [ <namespace> swap set-gadget-gestures ] keep
    [ t swap set-gadget-relayout? ] keep
    [ t swap set-gadget-redraw? ] keep ;

: redraw ( gadget -- )
    #! Redraw a gadget before the next iteration of the event
    #! loop.
    t over set-gadget-redraw?
    gadget-parent [ redraw ] when* ;

: relayout ( gadget -- )
    #! Relayout a gadget before the next iteration of the event
    #! loop. Since relayout also implies the visual
    #! representation changed, we redraw the gadget too.
    t over set-gadget-redraw?
    t over set-gadget-relayout?
    gadget-parent [ relayout ] when* ;

: move-gadget ( x y gadget -- )
    [ move-shape ] keep redraw ;

: resize-gadget ( w h gadget -- )
    [ resize-shape ] keep redraw ;

: remove-gadget ( gadget box -- )
    [ 2dup gadget-children remq swap set-gadget-children ] keep
    relayout
    f swap set-gadget-parent ;

: (add-gadget) ( gadget box -- )
    [ gadget-children cons ] keep set-gadget-children ;

: unparent ( gadget -- )
    dup gadget-parent dup [ remove-gadget ] [ 2drop ] ifte ;

: add-gadget ( gadget box -- )
    #! Add a gadget to a box.
    over unparent
    dup pick set-gadget-parent
    tuck (add-gadget)
    relayout ;

: each-parent ( gadget quot -- )
    #! Apply quotation to each parent of the gadget in turn,
    #! stopping when the quotation returns f.
    [ call ] 2keep rot [
        >r gadget-parent dup [
            r> each-parent
        ] [
            r> 2drop
        ] ifte
    ] [
        2drop
    ] ifte ;

: screen-pos ( gadget -- point )
    #! The position of the gadget on the screen.
    0 swap [ shape-pos + t ] each-parent ;

: child? ( parent child -- ? )
    dup [
        2dup eq? [ 2drop t ] [ gadget-parent child? ] ifte
    ] [
        2drop f
    ] ifte ;
