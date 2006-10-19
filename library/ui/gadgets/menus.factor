! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets
USING: arrays errors freetype gadgets-frames generic hashtables
kernel math models namespaces opengl sequences ;

: menu-loc ( world menu -- loc )
    >r rect-dim r> pref-dim [v-] hand-loc get-global vmin ;

TUPLE: menu-glass ;

C: menu-glass ( menu world -- glass )
    dup delegate>gadget
    >r over menu-loc over set-rect-loc r>
    [ add-gadget ] keep ;

M: menu-glass layout* gadget-child prefer ;

: retarget-drag ( gadget -- )
    hand-gadget get-global hand-clicked get-global eq? [
        drop
    ] [
        hand-loc get-global swap find-world move-hand
    ] if ;

\ menu-glass H{
    { T{ button-up } [ find-world [ hide-glass ] when* ] }
    { T{ drag } [ retarget-drag ] }
} set-gestures

: show-menu ( gadget owner -- )
    find-world [ <menu-glass> ] keep [ show-glass ] keep
    t menu-mode? set-global ;
