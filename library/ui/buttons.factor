! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: generic kernel lists math namespaces sdl ;

: button-pressed  ( button -- )
    dup f bevel-up? set-paint-property redraw ;

: button-released ( button -- )
    dup t bevel-up? set-paint-property redraw ;

: <button> ( label quot -- button )
    >r <label> bevel-border
    dup [ dup button-released ] r> append
    [ button-up 1 ] set-action
    dup [ button-pressed ]
    [ button-down 1 ] set-action ;
