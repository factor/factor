! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: kernel math namespaces prettyprint sdl ;

: drag-sizer ( sizer -- )
    gadget-parent ( - halo) [
        dup hand relative >rect
        rot halo-selected resize-gadget
    ] keep relayout ;

: sizer-actions ( sizer -- )
    dup [ drop ] [ button-down 1 ] set-action
    [ drag-sizer ] [ drag 1 ] set-action ;

: <sizer> ( -- sizer )
    0 0 10 10 <plain-rect> <gadget>
    dup sizer-actions ;

! A halo retains the gadget its surrounding, as well as the
! resizing gadget and a delegate.
TUPLE: halo selected sizer delegate ;

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

DEFER: halo-menu

: halo-actions ( gadget -- )
    dup [ halo-selected hand grab ] [ button-down 1 ] set-action
    dup [ halo-selected show-halo ] [ button-down 2 ] set-action
    [ halo-menu ] [ button-down 3 ] set-action ;

C: halo ( -- halo )
    0 0 0 0 <hollow-rect> <gadget> over set-halo-delegate
    dup red foreground set-paint-property
    dup red background set-paint-property
    <sizer> over 2dup set-halo-sizer add-gadget
    dup halo-actions ;

: halo-update ( halo -- )
    #! Move the halo to the position of its selected gadget.
    dup halo-selected
    2dup screen-pos >rect rot move-gadget
    dup shape-w swap shape-h rot resize-gadget ;

: sizer-layout ( halo -- )
    #! Position the sizer to the bottom right corner.
    dup halo-sizer
    over shape-h over shape-h -
    >r over shape-w over shape-w - r> rot move-gadget drop ;

M: halo layout* ( halo -- )
    dup halo-update sizer-layout ;

: default-actions ( gadget -- )
    [ show-halo ] [ button-down 2 ] set-action ;

