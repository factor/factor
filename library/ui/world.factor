! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets
USING: arrays errors freetype gadgets-frames generic hashtables
kernel math models namespaces opengl sequences ;

! The world gadget is the top level gadget that all (visible)
! gadgets are contained in. There is one world per top-level
! native window.

! fonts: mapping font tuples to sprite vectors
! handle: native resource
! loc: location of native window on the screen.
!   we don't store this in the world's rect-loc, since the
!   co-ordinate system might be different, and generally the
!   UI code assumes that everything starts at { 0 0 }.
TUPLE: world
active?
gadget glass
title status
focus focused?
fonts handle
loc ;

: free-fonts ( world -- )
    dup world-handle select-gl-context
    world-fonts hash-values [ second free-sprites ] each ;

DEFER: request-focus

C: world ( gadget -- world )
    f <model> over set-world-status
    [ >r dup gadget-title r> set-world-title ] keep
    { { f set-world-gadget f @center } } make-frame*
    t over set-gadget-root?
    t over set-world-active?
    H{ } clone over set-world-fonts
    { 0 0 } over set-world-loc
    dup world-gadget request-focus ;

: find-world [ world? ] find-parent ;

M: world pref-dim*
    delegate pref-dim* [ >fixnum ] map { 1024 768 } vmin ;

M: world graft*
    dup dup world-title add-connection
    dup dup world-status add-connection
    model-changed ;

M: world ungraft*
    dup
    dup world-title remove-connection
    dup world-status remove-connection ;

M: world model-changed
    dup world-title model-value swap set-title ;

: focused-ancestors ( world -- seq )
    world-focus parents <reversed> ;

: font-sprites ( font world -- pair )
    world-fonts [ lookup-font V{ } clone 2array ] cache ;

: draw-string ( font string -- )
    >r world get font-sprites first2 r> (draw-string) ;

M: world gadget-title world-gadget gadget-title ;

M: world layout*
    dup delegate layout*
    dup world-glass [
        >r dup rect-dim r> set-layout-dim
    ] when* drop ;

: hide-glass ( world -- )
    f menu-mode? set-global
    dup world-glass [ unparent ] when*
    f swap set-world-glass ;

: show-glass ( gadget world -- )
    [ hide-glass ] keep
    [ add-gadget ] 2keep
    set-world-glass ;
