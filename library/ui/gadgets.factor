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

DEFER: default-actions

C: gadget ( shape -- gadget )
    [ set-gadget-delegate ] keep
    [ <namespace> swap set-gadget-paint ] keep
    [ <namespace> swap set-gadget-gestures ] keep
    [ t swap set-gadget-relayout? ] keep
    [ t swap set-gadget-redraw? ] keep
    dup default-actions ;

: <empty-gadget> ( -- gadget )
    0 0 0 0 <rectangle> <gadget> ;

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
    #! This is inefficient.
    [ gadget-children swap unit append ] keep
    set-gadget-children ;

: unparent ( gadget -- )
    dup gadget-parent dup [ remove-gadget ] [ 2drop ] ifte ;

: add-gadget ( gadget box -- )
    #! Add a gadget to a box.
    over unparent
    dup pick set-gadget-parent
    tuck (add-gadget)
    relayout ;

: (parent-list) ( gadget -- )
    [ dup gadget-parent (parent-list) , ] when* ;

: parent-list ( gadget -- list )
    #! A list of all parents of the gadget, including the
    #! gadget itself.
    [ (parent-list) ] make-list ;

: (each-parent) ( list quot -- ? )
    over [
        over car gadget-paint [
            2dup >r >r >r cdr r> (each-parent) [
                r> car r> call
            ] [
                r> r> 2drop f
            ] ifte
        ] bind
    ] [
        2drop t
    ] ifte ; inline

: each-parent ( gadget quot -- ? )
    #! Keep executing the quotation on higher and higher
    #! parents until it returns f.
    >r parent-list r> (each-parent) ; inline

: screen-pos ( gadget -- point )
    #! The position of the gadget on the screen.
    0 swap [ shape-pos + t ] each-parent drop ;

: relative ( g1 g2 -- g2-p1 )
    shape-pos swap screen-pos - ;

: child? ( parent child -- ? )
    dup [
        2dup eq? [ 2drop t ] [ gadget-parent child? ] ifte
    ] [
        2drop f
    ] ifte ;
