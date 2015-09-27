! Copyright (C) 2005, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors combinators kernel math.vectors namespaces
ui.gadgets ui.gadgets.packs ui.gadgets.private ;
IN: ui.gadgets.incremental

TUPLE: incremental < pack cursor ;

: <incremental> ( -- incremental )
    incremental new
        vertical >>orientation
        { 0 0 } >>cursor ;

M: incremental pref-dim*
    dup layout-state>> [
        dup call-next-method >>cursor
    ] when cursor>> ;

: next-cursor ( gadget incremental -- cursor )
    [
        [ dim>> ] [ cursor>> ] bi*
        [ vmax ] [ v+ ] 2bi
    ] keep orientation>> set-axis ;

: update-cursor ( gadget incremental -- )
    [ nip ] [ next-cursor ] 2bi >>cursor drop ;

: incremental-loc ( gadget incremental -- )
    [ cursor>> ] [ orientation>> ] bi v*
    >>loc drop ;

: prefer-incremental ( gadget -- )
    dup forget-pref-dim prefer ;

M: incremental dim-changed drop ;

: add-incremental ( gadget incremental -- )
    not-in-layout
    2dup (add-gadget)
    t in-layout? [
        {
            [ drop prefer-incremental ]
            [ drop layout-later ]
            [ incremental-loc ]
            [ update-cursor ]
            [ nip prefer-incremental ]
            [ nip parent>> [ invalidate* ] when* ]
        } 2cleave
    ] with-variable ;

: clear-incremental ( incremental -- )
    not-in-layout
    [ (clear-gadget) ]
    [ forget-pref-dim ]
    [ { 0 0 } >>cursor parent>> [ relayout ] when* ]
    tri ;
