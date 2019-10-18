! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets
USING: arrays errors freetype gadgets generic hashtables
kernel math models namespaces opengl sequences ;

: menu-loc ( world menu -- loc )
    >r rect-dim r> pref-dim [v-] hand-loc get-global vmin ;

TUPLE: menu-glass ;

C: menu-glass ( menu world -- glass )
    dup delegate>gadget
    >r over menu-loc over set-rect-loc r>
    [ add-gadget ] keep ;

M: menu-glass layout* gadget-child prefer ;

: hide-glass ( world -- )
    dup world-glass [ unparent ] when*
    f swap set-world-glass ;

: show-glass ( gadget world -- )
    over hand-clicked set-global
    [ hide-glass ] keep
    [ add-gadget ] 2keep
    set-world-glass ;

: show-menu ( gadget owner -- )
    find-world [ <menu-glass> ] keep show-glass ;

\ menu-glass H{
    { T{ button-down } [ find-world [ hide-glass ] when* ] }
    { T{ drag } [ update-clicked drop ] }
} set-gestures
