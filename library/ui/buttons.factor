! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: generic kernel lists math namespaces sdl ;

: button-pressed  ( button -- )
    dup f bevel-up? set-paint-property redraw ;

: button-released ( button -- )
    dup t bevel-up? set-paint-property redraw ;

: mouse-over? ( gadget -- ? ) my-hand hand-gadget child? ;

: rollover-update ( button -- )
    dup mouse-over? blue black ? foreground set-paint-property ;

: button-pressed? ( button -- ? )
    dup mouse-over? [
        my-hand hand-buttons 1 swap contains? [
            my-hand hand-clicked child?
        ] [
            drop f
        ] ifte
    ] [
        drop f
    ] ifte ;

: bevel-update ( button -- )
    dup button-pressed? not bevel-up? set-paint-property ;

: button-update ( button -- )
    dup rollover-update dup bevel-update redraw ;

: button-clicked ( button -- )
    #! If the mouse is released while still inside the button,
    #! fire an action gesture.
    dup button-update
    dup mouse-over? [
        [ action ] swap handle-gesture drop
    ] [
        drop
    ] ifte ;

: button-actions ( button quot -- )
    dupd [ action ] set-action
    dup [ button-clicked ] [ button-up 1 ] set-action
    dup [ button-update ] [ button-down 1 ] set-action
    dup [ button-update ] [ mouse-leave ] set-action
    [ button-update ] [ mouse-enter ] set-action ;

: <button> ( label quot -- button )
    >r <label> bevel-border dup r> button-actions ;

: <check> ( w h -- cross )
    2dup >r >r 0 0 r> r> <line> <gadget>
    >r tuck neg >r >r >r 0 r> r> r> <line> <gadget> r>
    2list <stack> ;

TUPLE: checkbox bevel selected? delegate ;

: init-checkbox-bevel ( bevel checkbox -- )
    2dup set-checkbox-bevel add-gadget ;

: update-checkbox ( checkbox -- )
    #! Really, there should only be one child.
    dup checkbox-bevel gadget-children [ unparent ] each
    dup checkbox-selected? [
        11 11 <check>
    ] [
        0 0 11 11 <rectangle> <gadget>
    ] ifte swap checkbox-bevel add-gadget ;

: toggle-checkbox ( checkbox -- )
    dup checkbox-selected? not over set-checkbox-selected?
    update-checkbox ;

C: checkbox ( label -- checkbox )
    0 0 0 0 <rectangle> <shelf> over set-checkbox-delegate
    [ >r <label> r> add-gadget ] keep
    [ f bevel-border swap init-checkbox-bevel ] keep
    dup [ toggle-checkbox ] button-actions
    dup update-checkbox ;
