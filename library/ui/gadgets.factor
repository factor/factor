! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: generic hashtables kernel lists namespaces ;

! A gadget is a shape, a paint, a mapping of gestures to
! actions, and a reference to the gadget's parent. A gadget
! delegates to its shape.
TUPLE: gadget paint gestures parent relayout? redraw? delegate ;

! Gadget protocol.
GENERIC: pick-up* ( point gadget -- gadget/t )

: pick-up ( point gadget -- gadget )
    #! pick-up* returns t to mean 'this gadget', avoiding the
    #! exposed facade issue.
    tuck pick-up* dup t = [ drop ] [ nip ] ifte ;

GENERIC: gadget-children ( gadget -- list )
M: gadget gadget-children drop f ;

GENERIC: layout* ( gadget -- )
M: gadget layout* drop ;

: layout ( gadget -- )
    #! Set the gadget's width and height to its preferred width
    #! and height. The gadget's children are laid out first.
    #! Note that nothing is done if the gadget does not need to
    #! be laid out.
    dup gadget-relayout? [
        f over set-gadget-relayout?
        dup gadget-children [ layout ] each
        layout*
    ] [
        drop
    ] ifte ;

C: gadget ( shape -- gadget )
    [ set-gadget-delegate ] keep
    [ <namespace> swap set-gadget-paint ] keep
    [ <namespace> swap set-gadget-gestures ] keep
    [ t swap set-gadget-relayout? ] keep
    [ t swap set-gadget-redraw? ] keep ;

: paint-property ( gadget key -- value )
    swap gadget-paint hash ;

: set-paint-property ( gadget value key -- )
    rot gadget-paint set-hash ;

: action ( gadget gesture -- quot )
    swap gadget-gestures hash ;

: set-action ( gadget quot gesture -- )
    rot gadget-gestures set-hash ;

: draw-gadget ( gadget -- )
    #! All drawing done inside draw-shape is done with the
    #! gadget's paint. If the gadget does not have any custom
    #! paint, just call the quotation.
    dup gadget-paint [ draw-shape ] bind ;

M: gadget pick-up* inside? ;

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
