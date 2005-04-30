! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: errors generic hashtables kernel lists math namespaces
sdl ;

: layout ( gadget -- )
    #! Set the gadget's width and height to its preferred width
    #! and height. The gadget's children are laid out first.
    #! Note that nothing is done if the gadget does not need to
    #! be laid out.
    dup gadget-relayout? [
        f over set-gadget-relayout?
        dup gadget-paint [
            dup layout*
            gadget-children [ layout ] each
        ] bind
    ] [
        drop
    ] ifte ;

: with-pref-size ( quot -- )
    [
        0 width set  0 height set  call  width get height get
    ] with-scope ; inline

: with-layout ( quot -- )
    [ 0 x set 0 y set call ] with-scope ; inline

: default-gap 3 ;
