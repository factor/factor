! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: kernel math namespaces sdl ;

! The halo is used to move and resize gadgets.

: grab ( gadget hand -- )
    [ swap screen-pos swap screen-pos - >rect ] 2keep
    >r [ move-gadget ] keep r> add-gadget ;

: release ( gadget world -- )
    >r dup screen-pos >r dup unparent
    r> >rect pick move-gadget
    r> add-gadget ;

: moving-actions ( gadget -- )
    dup
    [ my-hand grab ] [ button-down 1 ] set-action
    [ world get release ] [ button-up 1 ] set-action ;
