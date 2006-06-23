! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets
USING: arrays errors freetype gadgets-frames generic hashtables
kernel math namespaces opengl sequences ;

! The world gadget is the top level gadget that all (visible)
! gadgets are contained in. There is one world per top-level
! native window.

! fonts: mapping font tuples to sprite vectors
! handle: native resource
! loc: location of native window on the screen.
!   we don't store this in the world's rect-loc, since the
!   co-ordinate system might be different, and generally the
!   UI code assumes that everything starts at { 0 0 }.
TUPLE: world gadget status focus focused? fonts handle loc ;

: free-fonts ( world -- )
    dup world-handle select-gl-context
    world-fonts hash-values [ second free-sprites ] each ;

DEFER: request-focus

C: world ( gadget status -- world )
    {
        { [ ] set-world-status @bottom }
        { [ ] set-world-gadget @center }
    } make-frame*
    t over set-gadget-root?
    H{ } clone over set-world-fonts
    dup world-gadget request-focus
    { 0 0 } over set-world-loc ;

: find-world [ world? ] find-parent ;

M: world pref-dim* ( world -- dim )
    delegate pref-dim* { 1024 768 } vmin ;

: focused-ancestors ( world -- seq )
    world-focus parents <reversed> ;

: font-sprites ( font world -- { open-font sprites } )
    world-fonts [ lookup-font V{ } clone 2array ] cache ;

: draw-string ( font string -- )
    >r world get font-sprites first2 r> (draw-string) ;
