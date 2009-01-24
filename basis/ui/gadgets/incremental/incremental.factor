! Copyright (C) 2005, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: io kernel math namespaces math.vectors ui.gadgets
ui.gadgets.packs accessors math.geometry.rect ;
IN: ui.gadgets.incremental

TUPLE: incremental < pack cursor ;

: <incremental> ( -- incremental )
    incremental new-gadget
        { 0 1 } >>orientation
        { 0 0 } >>cursor ;

M: incremental pref-dim*
    dup layout-state>> [
        dup call-next-method >>cursor
    ] when cursor>> ;

: next-cursor ( gadget incremental -- cursor )
    [
        [ rect-dim ] [ cursor>> ] bi*
        [ vmax ] [ v+ ] 2bi
    ] keep orientation>> set-axis ;

: update-cursor ( gadget incremental -- )
    [ nip ] [ next-cursor ] 2bi >>cursor drop ;

: incremental-loc ( gadget incremental -- )
    [ cursor>> ] [ orientation>> ] bi v*
    >>loc drop ;

: prefer-incremental ( gadget -- ) USE: slots.private
    dup forget-pref-dim dup pref-dim >>dim drop ;

M: incremental dim-changed drop ;

: add-incremental ( gadget incremental -- )
    not-in-layout
    2dup swap (add-gadget) drop
    t in-layout? [
        over prefer-incremental
        over layout-later
        2dup incremental-loc
        tuck update-cursor
        dup prefer-incremental
        parent>> [ invalidate* ] when*
    ] with-variable ;

: clear-incremental ( incremental -- )
    not-in-layout
    dup (clear-gadget)
    dup forget-pref-dim
    { 0 0 } >>cursor
    parent>> [ relayout ] when* ;
