! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: generic io kernel lists math namespaces prettyprint sdl
sequences sequences styles threads ;

: button-down? ( n -- ? ) hand hand-buttons member? ;

: mouse-over? ( gadget -- ? ) hand hand-gadget child? ;

: button-pressed? ( button -- ? )
    #! Return true if the mouse was clicked on the button, and
    #! is currently over the button.
    dup mouse-over? [
        1 button-down?
        [ hand hand-clicked child? ] [ drop f ] ifte
    ] [
        drop f
    ] ifte ;

: button-update ( button -- )
    dup dup mouse-over? rollover set-paint-prop
    dup dup button-pressed? reverse-video set-paint-prop
    relayout ;

: button-clicked ( button -- )
    #! If the mouse is released while still inside the button,
    #! fire an action gesture.
    dup button-update dup mouse-over?
    [ [ action ] swap handle-gesture ] when drop ;

: button-theme ( button -- )
    dup { 216 216 216 } background set-paint-prop
    dup f reverse-video set-paint-prop
    << solid f >> interior set-paint-prop ;

: roll-button-theme ( button -- )
    dup f reverse-video set-paint-prop
    dup <rollover-only> interior set-paint-prop
    <rollover-only> boundary set-paint-prop ;

: button-action ( action -- quot )
    [ [ swap handle-gesture drop ] cons ] [ [ drop ] ] ifte* ;

: button-gestures ( button quot -- )
    dupd [ action ] set-action
    dup [ button-clicked ] [ button-up 1 ] set-action
    dup [ button-update ] [ button-down 1 ] set-action
    dup [ button-update ] [ mouse-leave ] set-action
    [ button-update ] [ mouse-enter ] set-action ;

TUPLE: button ;

C: button ( gadget quot -- button )
    rot bevel-border over set-delegate
    dup button-theme [ swap button-gestures ] keep ;

: <roll-button> ( gadget quot -- button )
    >r dup roll-button-theme dup r> button-gestures ;

: repeat-button-down ( button -- )
    dup 100 add-timer button-clicked ;

: repeat-button-up ( button -- )
    dup button-update remove-timer ;

: repeat-actions ( button -- )
    dup [ repeat-button-down ] [ button-down 1 ] set-action
    [ repeat-button-up ] [ button-up 1 ] set-action ;

: <repeat-button> ( gadget quot -- button )
    #! Button that calls the quotation every 100ms as long as
    #! the mouse is held down.
    <button> dup repeat-actions ;

M: button tick ( ms object -- ) nip button-clicked ;
