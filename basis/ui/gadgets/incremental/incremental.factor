! Copyright (C) 2005, 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors combinators grouping kernel math math.vectors
namespaces sequences threads ui.gadgets ui.gadgets.packs
ui.gadgets.private ;
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

: scroll-children ( incremental -- )
    dup children>> length 200,000 > [
        ! We let the length oscillate between 100k-200k, so we don't
        ! have to relayout the container every time a gadget is added.
        [ 100,000 index-or-length cut* ] change-children

        ! Unfocus if any focused gadgets were removed and relayout
        dup focus>> pick member-eq? [ f >>focus ] when relayout yield

        ! Then we finish unparenting the scrolled of gadgets. Yield
        ! every 10k gadget so to not overflow the ungraft queue.
        10 <groups> [ [ (unparent) ] each yield ] each
    ] [ drop ] if ;

: add-incremental ( gadget incremental -- )
    not-in-layout
    dup scroll-children
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
