! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: kernel math namespaces prettyprint sdl ;

TUPLE: halo selected delegate ;

: gadget-menu ( gadget -- assoc )
    [
        [[ "Inspect" [ inspect ] ]]
        [[ "Unparent" [ unparent ] ]]
        [[ "Move" [ hand grab ] ]]
    ] actionize ;

: halo-menu ( halo -- )
    halo-selected gadget-menu <menu> show-menu ;

: show-halo* ( gadget -- )
    #! Show the halo on a specific gadget.
    halo
    [ world get add-gadget ] keep
    [ set-halo-selected ] keep relayout ;

: hide-halo ( -- )
    halo f over set-halo-selected  unparent ;

: parent-selected? ( gadget halo -- ? )
    #! See if the parent of a gadget is selected with a halo.
    halo-selected dup [ swap child? ] [ 2drop f ] ifte ;

: show-halo ( gadget -- )
    #! If a halo is already showing on the gadget, go to the
    #! parent.
    halo halo-selected world get eq? [
        drop hide-halo
    ] [
        dup halo parent-selected? [
            drop halo halo-selected gadget-parent 
        ] when show-halo*
    ] ifte ;

: halo-actions ( gadget -- )
    dup [ halo-selected hand grab ] [ button-down 1 ] set-action
    dup [ halo-selected show-halo ] [ button-down 2 ] set-action
    [ halo-menu ] [ button-down 3 ] set-action ;

C: halo ( -- halo )
    0 0 0 0 <hollow-rect> <gadget> over set-halo-delegate
    dup red foreground set-paint-property
    dup halo-actions ;

M: halo layout* ( halo -- )
    dup halo-selected
    2dup screen-pos >rect rot move-gadget
    dup shape-w swap shape-h rot resize-gadget ;

: default-actions ( gadget -- )
    [ show-halo ] [ button-down 2 ] set-action ;

