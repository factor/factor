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
    t over set-gadget-redraw?  gadget-parent [ redraw ] when* ;

: relayout ( gadget -- )
    #! Relayout a gadget before the next iteration of the event
    #! loop. Since relayout also implies the visual
    #! representation changed, we redraw the gadget too.
    t over set-gadget-redraw?
    t over set-gadget-relayout?
    gadget-parent [ relayout ] when* ;

: move-gadget ( x y gadget -- ) [ move-shape ] keep redraw ;
: resize-gadget ( w h gadget -- ) [ resize-shape ] keep redraw ;

: paint-prop ( gadget key -- value ) swap gadget-paint hash ;
: set-paint-prop ( gadget value key -- ) rot gadget-paint set-hash ;

GENERIC: pref-size ( gadget -- w h )
M: gadget pref-size shape-size ;

GENERIC: layout* ( gadget -- )

: prefer ( gadget -- ) [ pref-size ] keep resize-gadget ;

M: gadget layout*
    #! Trivial layout gives each child its preferred size.
    gadget-children [ prefer ] each ;

GENERIC: user-input* ( ch gadget -- ? )
M: gadget user-input* 2drop t ;
